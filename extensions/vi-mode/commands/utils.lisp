(defpackage :lem-vi-mode/commands/utils
  (:use :cl
        :lem)
  (:import-from :lem-vi-mode/core
                :*this-motion-command*
                :vi-command
                :vi-motion
                :vi-motion-type
                :vi-motion-default-n-arg
                :vi-operator
                :vi-text-object
                :current-state
                :change-state
                :range
                :make-range
                :range-beginning
                :range-end
                :range-type
                :operator-abort
                :text-object-abort
                :text-object-abort-range)
  (:import-from :lem-vi-mode/states
                :operator)
  (:import-from :lem-vi-mode/jump-motions
                :with-jump-motion)
  (:import-from :lem-vi-mode/visual
                :visual-p
                :visual-line-p
                :visual-block-p
                :visual-range
                :vi-visual-end)
  (:import-from :lem/common/command
                :ensure-command)
  (:import-from :alexandria
                :with-gensyms
                :ensure-list
                :ignore-some-conditions)
  (:export :bolp
           :eolp
           :goto-eol
           :fall-within-line
           :operator-pending-mode-p
           :read-universal-argument
           :*cursor-offset*
           :define-motion
           :define-operator
           :define-text-object-command))
(in-package :lem-vi-mode/commands/utils)

(defvar *cursor-offset* -1)
(defvar *operator-pending-mode* nil)

(defun bolp (point)
  "Return t if POINT is at the beginning of a line."
  (zerop (point-charpos point)))

(defun eolp (point)
  "Return t if POINT is at the end of line."
  (let ((len (length (line-string point))))
    (or (zerop len)
        (>= (point-charpos point)
            (1- len)))))

(defun goto-eol (point)
  "Goto end of a line."
  (line-end point)
  (unless (bolp point)
    (character-offset point *cursor-offset*)))

(defun fall-within-line (point)
  (when (eolp point)
    (goto-eol point)))

(defun operator-pending-mode-p ()
  *operator-pending-mode*)

(defun read-universal-argument ()
  (loop :for key := (read-key)
        :for char := (key-to-char key)
        :while (and char (digit-char-p char))
        :collect (digit-char-p char) :into digits
        :finally (unread-key key)
                 (return-from read-universal-argument
                   (and digits
                        (parse-integer (format nil "~{~D~}" digits))))))

(defmethod execute :around (mode (command vi-operator) uarg)
  (declare (ignore mode uarg))
  ;; XXX: This flag will be rewritten as a code to check the current state
  ;;   when operator-pending state is implemented.
  (let ((*operator-pending-mode* t)
        (*this-motion-command* nil))
    (handler-case (call-next-method)
      (operator-abort ()))))

(defvar *vi-origin-point*)

(defun parse-motion-arg-list (arg-list)
  (check-type arg-list list)
  (cond
    ((null arg-list)
     (values () ()))
    ((eq (first arg-list) '&optional)
     (values
       arg-list
       '("p")
       (second (ensure-list (second arg-list)))))
    (t (values arg-list '("P") nil))))

(defmacro define-motion (name arg-list arg-descriptors (&key type jump (repeat :motion) (default-n-arg 1)) &body body)
  (check-type type (or null (member :inclusive :exclusive :line :block)))
  (check-type jump boolean)
  `(define-command (,name (:advice-classes vi-motion)
                          (:initargs
                           :type ,(or type :exclusive)
                           :repeat ,repeat
                           :default-n-arg ,default-n-arg))
       ,arg-list ,arg-descriptors
     (with-point ((*vi-origin-point* (current-point)))
       (,(if jump 'with-jump-motion 'progn)
        ,@body))))

(defun call-motion-command (command n)
  (let* ((command (ensure-command command))
         (n (or n
                (typecase command
                  (vi-motion
                    (vi-motion-default-n-arg command))
                  (otherwise 1))))
         (lem-core::*universal-argument* n))
    (execute (lem-core::get-active-modes-class-instance (current-buffer))
             command
             n)))

(defun motion-region (motion)
  (check-type motion (or null symbol))
  (with-point ((start (current-point)))
    (labels ((call-motion (command uarg)
               (setf *this-motion-command* command)
               (let ((*cursor-offset* 0))
                 (save-excursion
                   (let ((retval (call-motion-command command uarg)))
                     (typecase retval
                       (range
                        (values (range-beginning retval)
                                (range-end retval)
                                (or (range-type retval) :exclusive)))
                       (otherwise
                        (values start
                                (copy-point (current-point))
                                (command-motion-type command))))))))
             (command-motion-type (command)
               (if (typep command 'vi-motion)
                   (vi-motion-type command)
                   :exclusive)))
      (if motion
          (let ((command (get-command motion)))
            (call-motion command (universal-argument-of-this-command)))
          (let ((state (current-state)))
            (unwind-protect
                 (progn
                   (change-state 'operator)
                   (let* ((uarg (* (or (universal-argument-of-this-command) 1) (or (read-universal-argument) 1)))
                          (command-name (read-command))
                          (command (get-command command-name)))
                     (typecase command
                       (vi-operator
                        (if (eq command-name (command-name (this-command)))
                            ;; Recursive call of the operator like 'dd', 'cc'
                            (save-excursion
                              (ignore-some-conditions (end-of-buffer)
                                (next-logical-line (1- (or uarg 1))))
                              (values start (copy-point (current-point)) :line))
                            ;; Ignore an invalid operator (like 'dJ')
                            nil))
                       (otherwise
                        (call-motion command uarg)))))
              (change-state state)))))))

(defun visual-region ()
  (if (visual-p)
      (values-list
       (append (visual-range)
               (list
                (cond
                  ((visual-line-p) :line)
                  ((visual-block-p) :block)
                  (t :exclusive)))))
      (values nil nil nil)))

(defun operator-region (motion &key move-point with-type)
  (multiple-value-bind (start end type)
      (multiple-value-bind (start end type)
          (if (visual-p)
              (visual-region)
              (motion-region motion))
        (when (point< end start)
          (rotatef start end))
        (ecase type
          (:line (unless (visual-p)
                   (line-start start)
                   (line-end end)))
          (:block)
          (:inclusive
           (unless (point= start end)
             (character-offset end 1)))
          (:exclusive))
        (values start end type))
    (multiple-value-prog1
        (if with-type
            (values start end type)
            (values start end))
      (when move-point
        (move-point (current-point) start)))))

(defun call-define-operator (fn &key keep-visual restore-point)
  (with-point ((*vi-origin-point* (current-point)))
    (unwind-protect (funcall fn)
      (when restore-point
        (move-point (current-point) *vi-origin-point*))
      (unless keep-visual
        (when (visual-p)
          (vi-visual-end))))))

(defun parse-arg-descriptors (arg-descriptors &key motion move-point)
  `(values-list
    (append
     ,@(mapcar (lambda (arg-descriptor)
                 (if (stringp arg-descriptor)
                     (cond
                       ((string= arg-descriptor "<r>")
                        `(multiple-value-list (operator-region ',motion :move-point ,move-point)))
                       ((string= arg-descriptor "<R>")
                        `(multiple-value-list (operator-region ',motion :move-point ,move-point :with-type t)))
                       ((string= arg-descriptor "<v>")
                        '(multiple-value-list (visual-region)))
                       ((string= arg-descriptor "p")
                        '(list (or (universal-argument-of-this-command) 1)))
                       (t
                        (error "Unknown arg descriptor: ~S" arg-descriptor)))
                     `(multiple-value-list ,arg-descriptor)))
               arg-descriptors))))

(defmacro define-operator (name arg-list arg-descriptors
                           (&key motion keep-visual (move-point t) (repeat t) restore-point)
                           &body body)
  `(define-command (,name (:advice-classes vi-operator)
                          (:initargs :repeat ,repeat)) ,arg-list
       (,(parse-arg-descriptors arg-descriptors :motion motion :move-point move-point))
     (call-define-operator (lambda () ,@body)
                              :keep-visual ,keep-visual
                              :restore-point ,restore-point)))

(defun call-define-text-object-command (fn)
  (flet ((expand-visual-range (range)
           (let ((p1 (range-beginning range))
                 (p2 (range-end range)))
             (destructuring-bind (vstart vend)
                 (visual-range)
               (let ((forward (point<= vstart vend)))
                 (setf (visual-range)
                       (if forward
                           (list (point-min p1 vstart)
                                 (point-max p2 vend))
                           (list (point-max p1 vstart)
                                 (point-min p2 vend)))))))))
    (handler-bind ((text-object-abort
                     (lambda (e)
                       (when (visual-p)
                         (expand-visual-range (text-object-abort-range e))
                         (return-from call-define-text-object-command)))))
      (let ((range (funcall fn)))
        (when (visual-p)
          (expand-visual-range range))
        range))))

(defmacro define-text-object-command (name arg-list arg-descriptors
                                      &body body)
  `(define-command (,name (:advice-classes vi-text-object)) ,arg-list
       (,(parse-arg-descriptors arg-descriptors))
     (call-define-text-object-command (lambda () ,@body))))

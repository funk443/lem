(defpackage :lem/list-buffers
  (:use :cl
        :lem)
  (:import-from :lem/multi-column-list
                :multi-column-list
                :multi-column-list-item
                :select-item
                :delete-item
                :row-values
                :display
                :quit)
  (:export :list-buffers))
(in-package :lem/list-buffers)

(defclass buffer-menu (multi-column-list)
  ()
  (:default-initargs
   :columns '("" "Buffer" "File")
   :use-mark t))

(defclass item (multi-column-list-item)
  ((buffer :initarg :buffer
           :reader item-buffer)))

(defmethod row-values ((component buffer-menu) (item item))
  (let ((buffer (item-buffer item)))
    (list (string-trim " " (lem::buffer-attributes buffer))
          (buffer-name buffer)
          (buffer-filename buffer))))

(defmethod select-item ((component buffer-menu) item)
  (quit component)
  (switch-to-buffer (item-buffer item)))

(defmethod delete-item ((component buffer-menu) item)
  (kill-buffer (item-buffer item)))

(defun make-item (buffer)
  (make-instance 'item :buffer buffer))

(define-command list-buffers () ()
  (display
   (make-instance 'buffer-menu
                  :items (mapcar #'make-item (buffer-list)))))

(define-key *global-keymap* "C-x C-b" 'list-buffers)

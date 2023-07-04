(defpackage :lem-base
  (:use :cl)
  #+sbcl
  (:lock t)
  ;; utils.lisp
  (:export
   :collect-subclasses
   :utf8-bytes
   :bests-if
   :max-if
   :min-if
   :find-tree
   :do-sequence
   :if-push)
  ;; icon.lisp
  (:export :register-icon
           :register-icon-ext
           :icon-code-p
           :icon-string
           :icon-string-by-ext
           :icon-value)
  ;; string-width-utils.lisp
  (:export :+default-tab-size+
           :control-char
           :wide-char-p
           :char-width
           :string-width
           :wide-index)
  ;; file-utils.lisp
  (:export :expand-file-name
           :tail-of-pathname
           :directory-files
           :list-directory
           :file-size
           :copy-file-or-directory
           :virtual-probe-file
           :with-open-virtual-file)
  ;; errors.lisp
  (:export :editor-condition
           :directory-does-not-exist
           :directory-does-not-exist-directory
           :read-only-error
           :editor-error
           :scan-error
           :editor-interrupt)
  ;; hooks.lisp
  (:export :run-hooks
           :add-hook
           :remove-hook)
  ;; var.lisp
  (:export
   :editor-variable
   :define-editor-variable
   :clear-editor-local-variables
   :variable-value
   :variable-documentation
   :find-editor-variable
   :with-global-variable-value)
  ;; editor-variables.lisp
  (:export
   :tab-width)
  ;; macros.lisp
  (:export
   :save-excursion
   :with-point
   :with-buffer-read-only
   :without-interrupts)
  ;; mark.lisp
  (:export
   :mark
   :mark-point
   :mark-active-p
   :mark-cancel
   :mark-set-point)
  ;; buffer.lisp
  (:export
   :fundamental-mode
   :primordial-buffer
   :current-buffer
   :make-buffer
   :buffer
   :text-buffer
   :bufferp
   :buffer-start-point
   :buffer-end-point
   :deleted-buffer-p
   :buffer-name
   :buffer-temporary-p
   :buffer-modified-tick
   :buffer-modified-p
   :buffer-read-only-p
   :buffer-syntax-table
   :buffer-major-mode
   :buffer-minor-modes
   :buffer-mark-object
   :buffer-mark-p
   :buffer-mark
   :buffer-point
   :buffer-nlines
   :buffer-enable-undo-p
   :buffer-enable-undo
   :buffer-disable-undo
   :buffer-filename
   :buffer-directory
   :buffer-unmark
   :buffer-mark-cancel
   :buffer-attributes
   :buffer-rename
   :buffer-undo
   :buffer-redo
   :buffer-undo-boundary
   :buffer-value
   :buffer-unbound
   :clear-buffer-variables)
  ;; buffer-insert.lisp
  (:export
   :*inhibit-read-only*
   :*inhibit-modification-hooks*
   :before-change-functions
   :after-change-functions)
  ;; buffer-list-manager.lisp
  (:export
   :delete-buffer-using-manager
   :buffer-list-manager
   :with-current-buffer)
  ;; buffers.lisp
  (:export
   :kill-buffer-hook
   :buffer-list
   :any-modified-buffer-p
   :get-buffer
   :unique-buffer-name
   :delete-buffer
   :get-next-buffer
   :get-previous-buffer
   :unbury-buffer
   :bury-buffer
   :get-file-buffer)
  ;; point.lisp
  (:export
   :current-point
   :point
   :pointp
   :copy-point-using-class
   :copy-point
   :delete-point
   :point-buffer
   :point-charpos
   :point-kind
   :point=
   :point/=
   :point<
   :point<=
   :point>
   :point>=
   :point-closest
   :point-min
   :point-max)
  ;; basic.lisp
  (:export
   :first-line-p
   :last-line-p
   :start-line-p
   :end-line-p
   :start-buffer-p
   :end-buffer-p
   :same-line-p
   :move-point
   :line-start
   :line-end
   :buffer-start
   :buffer-end
   :line-offset
   :character-offset
   :character-at
   :line-string
   :text-property-at
   :put-text-property
   :remove-text-property
   :next-single-property-change
   :previous-single-property-change
   :insert-character
   :insert-string
   :delete-character
   :erase-buffer
   :region-beginning
   :region-end
   :map-region
   :points-to-string
   :count-characters
   :delete-between-points
   :count-lines
   :apply-region-lines
   :line-number-at-point
   :point-column
   :move-to-column
   :position-at-point
   :move-to-position
   :point-bytes
   :move-to-bytes
   :move-to-line
   :check-marked
   :set-current-mark
   :blank-line-p
   :skip-chars-forward
   :skip-chars-backward
   :insert-buffer
   :buffer-text)
  ;; syntax-table.lisp
  (:export
   :syntax-table
   :set-syntax-parser
   :fundamental-syntax-table
   :current-syntax
   :with-current-syntax
   :make-syntax-table
   :syntax-word-char-p
   :syntax-space-char-p
   :syntax-symbol-char-p
   :syntax-open-paren-char-p
   :syntax-closed-paren-char-p
   :syntax-string-quote-char-p
   :syntax-escape-char-p
   :syntax-expr-prefix-char-p
   :syntax-skip-expr-prefix-forward
   :syntax-skip-expr-prefix-backward)
  ;; search.lisp
  (:export
   :*case-fold-search*
   :search-forward
   :search-backward
   :search-forward-regexp
   :search-backward-regexp
   :search-forward-symbol
   :search-backward-symbol
   :looking-at
   :match-string-at)
  ;; syntax-scan.lisp
  (:export
   :skip-space-and-comment-forward
   :skip-space-and-comment-backward
   :form-offset
   :scan-lists
   :skip-whitespace-forward
   :skip-whitespace-backward
   :skip-symbol-forward
   :skip-symbol-backward
   :symbol-region-at-point
   :symbol-string-at-point
   :make-pps-state
   :pps-state-type
   :pps-state-token-start-point
   :pps-state-end-char
   :pps-state-block-comment-depth
   :pps-state-block-pair
   :pps-state-paren-stack
   :pps-state-paren-depth
   :parse-partial-sexp
   :syntax-ppss
   :pps-state-string-p
   :pps-state-comment-p
   :pps-state-string-or-comment-p
   :in-string-p
   :in-comment-p
   :in-string-or-comment-p
   :maybe-beginning-of-string
   :maybe-beginning-of-comment
   :maybe-beginning-of-string-or-comment)
  ;; syntax-parser.lisp
  (:export
   :syntax-string-attribute
   :syntax-comment-attribute
   :syntax-keyword-attribute
   :syntax-constant-attribute
   :syntax-function-name-attribute
   :syntax-variable-attribute
   :syntax-type-attribute
   :*global-syntax-highlight*
   :before-syntax-scan-hook
   :after-syntax-scan-hook
   :enable-syntax-highlight
   :enable-syntax-highlight-p
   :syntax-scan-region)
  ;; tmlanguage.lisp
  (:export
   :make-tmlanguage
   :make-tm-repository
   :make-tm-match
   :make-tm-region
   :make-tm-include
   :make-tm-patterns
   :make-tm-name
   :add-tm-repository
   :add-tm-pattern)
  ;; encodings.lisp
  (:export
   :encoding
   :encoding-read
   :encoding-write
   :register-encoding
   :encoding-end-of-line
   :unregister-encoding)
  ;; file.lisp
  (:export
   :*find-file-hook*
   :before-save-hook
   :after-save-hook
   :*external-format-function*
   :*find-directory-function*
   :*default-external-format*
   :encoding-read-error
   :insert-file-contents
   :find-file-buffer
   :write-to-file
   :write-region-to-file
   :update-changed-disk-date
   :changed-disk-p)
  ;; indent.lisp
  (:export
   :back-to-indentation
   :indent-tabs-mode
   :calc-indent-function
   :indent-when-yank
   :indent-line
   :indent-points
   :indent-buffer
   :insert-string-and-indent))

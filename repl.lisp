;;;; Tiny Lisp repl
;;;

#+org.tfeb.tools.require-module
(org.tfeb.tools.require-module:needs
 (:org.tfeb.hax.spam :compile t))

(defpackage :org.tfeb.tiny-eval.repl
  (:use :cl :org.tfeb.hax.spam)
  (:export
   #:repl
   #:*default-bindings*))

(in-package :org.tfeb.tiny-eval.repl)

(defparameter *default-bindings* nil)

(defvar *history* nil)

(defun repl (evaluator &key
                       (bindings *default-bindings*)
                       (boundp #'assoc)
                       (handle-errors t)
                       (history *history*)
                       (reset-history nil)
                       (prompt "?"))
  (when (or reset-history (not history))
    (setf history (make-array 100 :adjustable t :fill-pointer 0)
          *history* history))
  (dolist (meta '(:h :q))
    (when (funcall boundp meta bindings)
      (warn "~S is bound" meta)))
  (let ((end-of-history (length history))
        (eof-cookie (cons nil nil))
        (*print-pretty* t))
    (do ((read (progn
                 (format *standard-output* "~&~A " prompt)
                 (finish-output *standard-output*)
                 (read *standard-input* nil history))
               (progn
                 (format *standard-output* "~&~A " prompt)
                 (finish-output *standard-output*)
                 (read *standard-input* nil history))))
        ((eql read eof-cookie) (values))
      (flet ((ep/maybe-errors (form)
               (handler-bind ((error (lambda (e)
                                       (format *error-output* "~&Error: ~A~%" e)
                                       (when handle-errors
                                         (go end)))))
                 (dolist (v (multiple-value-list (funcall evaluator form bindings)))
                   (format *standard-output* "~%~S" v))
                 (terpri *standard-output*)
                 (finish-output *standard-output*))))
        (matching read
          ((is ':q)
           (return-from repl (values)))
          ((some-of
            (is ':h)
            (list-matches (is ':h)))
           (dotimes (item end-of-history)
             (format *standard-output* "~&~4D: ~S~%" item (aref history item))))
          ((list-matches (is ':h) (is-type 'integer))
           (let ((element (second read)))
             (cond
              ((>= element 0)
               (when (>= element end-of-history)
                 (warn "history ~D after end of history ~D" element end-of-history)
                 (go end))
               (format *standard-output* "~&~D: ~S" element (aref history element))
               (ep/maybe-errors (aref history element)))
              ((< element 0)
               (let ((effective (+ end-of-history element)))
                 (when (< effective 0)
                   (warn "only ~D history items" end-of-history)
                   (go end))
                 (format *standard-output* "~&~D (~D): ~S" element effective
                         (aref history effective))
                 (ep/maybe-errors (aref history effective)))))))
          (otherwise
           (vector-push-extend read history)
           (incf end-of-history)
           (ep/maybe-errors read))))
      end)))

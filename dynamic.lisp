;;;; A tiny dynamically-scoped evaluator
;;;

#+org.tfeb.tools.require-module
(org.tfeb.tools.require-module:needs
 ((:org.tfeb.hax.spam
   :org.tfeb.hax.iterate) :compile t)
 ("common" :compile t))

(defpackage :org.tfeb.tiny-eval.dynamic
  (:use :cl
   :org.tfeb.hax.spam
   :org.tfeb.hax.iterate
   :org.tfeb.tiny-eval.common)
  (:export #:evaluate/dynamic))

(in-package :org.tfeb.tiny-eval.dynamic)

;;; Procedures are represented as a structure: primitives are simply
;;; the naked underlying function rather than a wrapper around it.
;;;
(defstruct (procedure
            (:print-function
             (lambda (p s d)
               (declare (ignore d))
               (print-unreadable-object (p s)
                 (format s "λ ~S" (procedure-formals p))))))
  (formals '())
  (body '()))

(defun evaluate/dynamic (thing bindings)
  (evaluate thing bindings))

(defun evaluate (thing bindings)
  (typecase thing
    (symbol
     (let ((found (assoc thing bindings)))
       (unless found
         (error "~S unbound" thing))
       (cdr found)))
    (list
     (destructuring-bind (op . arguments) thing
       (case op
         ((lambda λ)
          (matching arguments
            ((head-matches (list-of #'symbolp))
             (make-procedure :formals (first arguments)
                             :body (rest arguments)))
            (otherwise
             (error "bad lambda form ~S" thing))))
         ((quote)
          (matching arguments
            ((list-matches (any))
             (first arguments))
            (otherwise
             (error "bad quote form ~S" thing))))
         ((if)
          (matching arguments
            ((list-matches (any) (any))
             (if (evaluate (first arguments) bindings)
                 (evaluate (second arguments) bindings)))
            ((list-matches (any) (any) (any))
             (if (evaluate (first arguments) bindings)
                 (evaluate (second arguments) bindings)
               (evaluate (third arguments) bindings)))
            (otherwise
             (error "bad if form ~S" thing))))
         ((set!)
          (matching arguments
            ((list-matches #'symbolp (any))
             (let ((found (assoc (first arguments) bindings)))
               (unless found
                 (error "~S unbound" (first arguments)))
               (setf (cdr found) (evaluate (second arguments) bindings))))
            (otherwise
             (error "bad set! form ~S" thing))))
         (t
          (applicate (evaluate (first thing) bindings)
                     (mapcar (lambda (form)
                               (evaluate form bindings))
                             (rest thing))
                     bindings)))))
    (t thing)))

(defun applicate (thing arguments bindings)
  (etypecase thing
    (function
     ;; a primitive
     (apply thing arguments))
    (procedure
     (iterate bind ((vtail (procedure-formals thing))
                    (atail arguments)
                    (extended-bindings bindings))
       (cond
        ((and (null vtail) (null atail))
         (iterate eval-body ((btail (procedure-body thing)))
           (if (null (rest btail))
               (evaluate (first btail) extended-bindings)
             (progn
               (evaluate (first btail) extended-bindings)
               (eval-body (rest btail))))))
        ((null vtail)
         (error "too many arguments"))
        ((null atail)
         (error "not enough arguments"))
        (t
         (bind (rest vtail)
               (rest atail)
               (acons (first vtail) (first atail)
                      extended-bindings))))))))

#||
(evaluate '((lambda (f)
              ((lambda (x)
                 (f))
               1))
            ((lambda (x)
               (lambda () x))
             2))
          '())
||#

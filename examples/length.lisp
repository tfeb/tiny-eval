;;;; How to compute length
;;;

(in-package :cl-user)
(use-package :org.tfeb.tiny-eval)

(setf *default-bindings*
      (mapcar (lambda (name)
                (etypecase name
                  (symbol
                   `(,name . ,(fdefinition name)))
                  (cons
                   `(,(first name) . ,(fdefinition (second name))))))
              '(car cdr cons (null? null) (cons? consp) (eqv? eql)
                    + - * / =)))

(defvar *length-lexical-broken*
  '((lambda (length)
      (length '(1 2 3)))
    (lambda (l)
      (if (null? l)
          0
        (+ (length (cdr l)) 1)))))

(defvar *length-lexical-assignment*
  '((lambda (length)
      (set! length (lambda (l)
                     (if (null? l)
                         0
                       (+ (length (cdr l)) 1))))
      (length '(1 2 3)))
    0))

(defvar *length-lexical-u*
  '((lambda (length)
      (length '(1 2 3)))
    (lambda (l)
      ((lambda (c)
         (c c l 0))
       (lambda (c t s)
         (if (null? t)
             s
           (c c (cdr t) (+ s 1))))))))

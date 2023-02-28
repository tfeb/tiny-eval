;;;; Common names for the tiny evaluators
;;;

#+org.tfeb.tools.require-module
(org.tfeb.tools.require-module:needs
 (:org.tfeb.conduit-packages :compile t))

(in-package :org.tfeb.clc-user)

(defpackage :org.tfeb.tiny-eval.common
  (:use)
  (:extends/including :cl quote lambda if)
  (:export #:set! #:λ))

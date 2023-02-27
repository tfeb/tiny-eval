;;;; Two tiny evaluators
;;;

#+org.tfeb.tools.require-module
(org.tfeb.tools.require-module:needs
 (:org.tfeb.conduit-packages :compile t)
 (("common"
   "lexical"
   "dynamic"
   "repl")
  :compile t))

(in-package :org.tfeb.clc-user)

(defpackage :org.tfeb.tiny-eval
  (:use)
  (:extends
   :org.tfeb.tiny-eval.common
   :org.tfeb.tiny-eval.lexical
   :org.tfeb.tiny-eval.dynamic
   :org.tfeb.tiny-eval.repl))

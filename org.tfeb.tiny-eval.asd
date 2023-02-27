;;;; ASDF sysdcl for the tiny evaluators
;;;

(in-package :asdf-user)

(defsystem "org.tfeb.tiny-eval"
  :description "Two tiny evaluators to play with"
  ;:version (:read-file-line "VERSION")
  :author "Tim Bradshaw"
  :license "MIT"
  ;:homepage "https://github.com/tfeb/tiny-eval"
  :depends-on ("org.tfeb.hax.iterate"
               "org.tfeb.hax.spam"
               "org.tfeb.conduit-packages")
  :components
  ((:file "common")
   (:file "lexical" :depends-on ("common"))
   (:file "dynamic" :depends-on ("common"))
   (:file "repl")
   (:file "tiny-eval" :depends-on ("common" "lexical" "dynamic" "repl"))))

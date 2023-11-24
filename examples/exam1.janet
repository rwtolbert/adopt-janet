#!/usr/bin/env janet
(import ../adopt)

(def args (adopt/argv))
(def arglen (length args))
(print arglen)
(print (first args))
(print (last args))

(def verb (adopt/make-option
             @{:name "verbose"
               :short "-v"
               :long "--verbose"
               :help "Add more verbose output."}))

(loop [key :in (keys verb)]
  (print key ":" (get verb key)))

(adopt/print-object verb)

(def badoption (adopt/make-option @{:name "badoption"}))

(adopt/exit 0)
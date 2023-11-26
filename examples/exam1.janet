#!/usr/bin/env janet
(import ../adopt)

(def args (adopt/argv))
(def arglen (length args))

(def verbose-option (adopt/make-option
           @{:name "verbose"
             :short "v"
             :long "verbose"
             :help "Add more verbose output."}))

(adopt/print-object verbose-option)
(loop [key :in (keys verbose-option)]
  (print "  " key ": " (get verbose-option key)))

(adopt/exit 0)
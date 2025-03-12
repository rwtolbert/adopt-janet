#!/usr/bin/env janet
(import ../adopt)

(def args (adopt/argv))
(def arglen (length args))

(def verbose-option
  (adopt/make-option @{:name 'verbose
                       :short "v"
                       :long "verbose"
                       :help "Add more verbose output."
                       :reduce (adopt/constantly true)}))

(def other-group
  (adopt/make-group @{:name 'other
                      :title "Other options"
                      :help "a set of things you rarely need"
                      :options @[verbose-option]}))

(def ui (adopt/make-interface @{:name "exam1"
                                :usage "[OPTIONS]"
                                :summary "Example 1"
                                :help "Help text"
                                # :manual (string/format "%s\n\n%s" help-text extra-manual-text)
                                # :examples *examples*
                                :contents @[other-group]}))

(adopt/print-help-and-exit ui :exit-code 0)

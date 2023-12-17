(use spork/test)

(import ../adopt)

(start-suite 'option)


(assert-error "must have help for option"
              (def badoption (adopt/make-option @{:name "badoption"})))

(assert-error "must have short or long"
              (def badoption (adopt/make-option @{:name "badoption" :help "help"})))

(assert-error "reducer function requires :parameter"
 (def *verbose-option* (adopt/make-option
                        @{:name "verbose"
                          :short "v"
                          :long "verbose"
                          :help "Add more verbose output."
                          :reduce adopt/utils/last-arg})))

(assert-no-error
 (def *verbose-option* (adopt/make-option
                        @{:name "verbose"
                          :short "v"
                          :long "verbose"
                          :help "Add more verbose output."
                          :reduce (adopt/constantly true)})))

(def *verbose-option* (adopt/make-option
                       @{:name "verbose"
                         :short "v"
                         :long "verbose"
                         :help "Add more verbose output."
                         :reduce (adopt/constantly true)
                         :finally (fn [x] (printf "final value for *verbose-option*: %q" x))}))
(adopt/print-option *verbose-option*)

(def *param-option* (adopt/make-option
                     @{:name "x"
                       :short "x"
                       :help "value for x"
                       :parameter true
                       :reduce (fn [old current] (printf "RRRR reduce for x old:%q current:%q" old current) current)}))

(def *long-only-option* (adopt/make-option
                         @{:name "long-only"
                           :long "long"
                           :help "This option only has a long version."
                           :parameter true
                           :reduce adopt/utils/last-arg}))
(print "foo " (*long-only-option* :long))
(print "bar " (*long-only-option* :short))
(adopt/print-option *long-only-option*)


(def *short-only-option* (adopt/make-option
                         @{:name "short-only"
                           :short "s"
                           :help "This option only has a short version."
                           :reduce (adopt/constantly true)}))
(print "foo " (*short-only-option* :long))
(print "bar " (*short-only-option* :short))
(adopt/print-option *short-only-option*)

(assert-no-error
 (def *bool-option* (adopt/make-boolean-options
                     @{:name "print"
                       :long "print"
                       :short "p"
                       :help "Print results"
                       :help-no "Don't print results"})))

(def [*bool-option* *bool-no-option*]
  (adopt/make-boolean-options
   @{:name "print"
     :long "print"
     :short "p"
     :help "Print results"
     :help-no "Don't print results"}))


(adopt/print-option *bool-option*)
(adopt/print-option *bool-no-option*)

(def *bool-group* (adopt/make-default-group [*bool-option* *bool-no-option*]))
(adopt/print-group *bool-group*)

(def *interface* (adopt/make-interface @{:name "main"
                                         :summary "main interface for program"
                                         :usage "main [options]"
                                         :help "this is the help for main"
                                         :contents [*verbose-option* *param-option* *long-only-option* *bool-group*]}))

(printf "########## short options %q" (keys (*interface* :short-options)))

(def argv @["-v" "--no-print" "-xfoo" "--long" "bar" "--" "a.txt" "b.txt"])
(printf "FINAL: %q\n\n" (adopt/parse-options *interface* argv))

(def argv @["-v" "-P" "-xfoo" "--long=bar" "--" "a.txt" "b.txt"])
(printf "FINAL: %q\n\n" (adopt/parse-options *interface* argv))

(def [args results] (adopt/parse-options *interface* argv))
(printf "INPUT:   %q" argv)
(printf "ARGS:    %q" args)
(printf "RESULTS: %q\n" results)

(def bad-argv @["-Q" "a.txt" "b.txt"])
(assert-error "Problematic option -Q"
  (adopt/parse-options *interface* bad-argv))

# (adopt/parse-options-or-exit *interface* bad-argv)

(end-suite)
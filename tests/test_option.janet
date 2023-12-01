(use spork/test)

(import ../adopt)

(start-suite 'option)

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
                         :reduce (adopt/constantly true)}))
(adopt/print-option *verbose-option*)

(def *long-only-option* (adopt/make-option
                         @{:name "long-only"
                           :long "long"
                           :help "This option only has a long version."
                           :reduce (adopt/constantly true)}))
(adopt/print-option *long-only-option*)


(def *short-only-option* (adopt/make-option
                         @{:name "short-only"
                           :short "s"
                           :help "This option only has a short version."
                           :reduce (adopt/constantly true)}))
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

(assert-error "must have help for option"
              (def badoption (adopt/make-option @{:name "badoption"})))

(assert-error "must have short or long"
              (def badoption (adopt/make-option @{:name "badoption" :help "help"})))

(end-suite)
(use spork/test)

(import ../adopt)

(start-suite 'option)

(assert-no-error
 (def verbose-option (adopt/make-option
                      @{:name "verbose"
                        :short "v"
                        :long "verbose"
                        :help "Add more verbose output."})))

(assert-error "must have help for option" 
              (def badoption (adopt/make-option @{:name "badoption"})))

(assert-error "must have short or long"
              (def badoption (adopt/make-option @{:name "badoption" :help "help"})))

(end-suite)
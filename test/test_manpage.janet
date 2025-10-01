(use spork/test)

(import ../adopt)

(start-suite 'manpage)

(defn ct [] (adopt/constantly true))

(def help-option (adopt/make-option @{:name 'help
                                      :reduce (ct)
                                      :help "Print help and exit."
                                      :long "help"
                                      :short "h"}))
(def other-group (adopt/make-group @{:name 'other
                                     :title "Other options"
                                     :help "These are seldom used options"
                                     :manual "Some other options you might want to use"
                                     :options @[help-option]}))

(def empty-group (adopt/make-group @{:name 'empty
                                     :title "Empty group"
                                     :manual "This group has no options and should not appear in the man page."
                                     :options @[]}))


# single/multiple usage
(def single-usage
  (adopt/make-interface @{:name "single"
                          :summary "Test interface for single flag"
                          :help ``It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.``
                          :usage @["[options] arg" "(-h | --help)"]
                          :examples @[["do foo" "single --foo FOO"] ["do foo and bar" "single --foo=FOO --bar"]]
                          :contents @[(adopt/make-option @{:name 'foo
                                                           :reduce (ct)
                                                           :help "Set foo"
                                                           :manual ``It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.``
                                                           :short "a"
                                                           :long "foo"
                                                           :parameter "FOO"})
                                      (adopt/make-option @{:name 'bar
                                                           :reduce (ct)
                                                           :help "Set bar"
                                                           :long "bar"})
                                      other-group
                                      empty-group]}))

(printf "--------------- man page output -----------------")
(adopt/print-manual single-usage)
(printf "--------------- man page end --------------------")

# dump to a local file to test
(def strm (file/open "manpage.1" :w))
(adopt/print-manual single-usage :stream strm)
(file/close strm)

(def data (file/read (file/open "manpage.1" :r) :all))
(assert (string/find "Some other opt" data))
(assert (not (string/find "seldom used" data)))
(assert (not (string/find "Empty" data)))

(os/rm "manpage.1")

(end-suite)

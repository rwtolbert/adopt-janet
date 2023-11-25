#!/usr/bin/env janet
(import ../adopt)

(def args (adopt/argv))
(def arglen (length args))
# (print arglen)
# (print (adopt/first-arg "foo" "bar"))
# (print (adopt/last-arg "foo" "bar"))

# (print (adopt/member 1 @[1 4 5]))
# (print (adopt/member 2 @[1 4 5]))
# (print (adopt/member adopt/last-arg @[adopt/first-arg adopt/collect adopt/last-arg]))

(var good "goodbye")

(adopt/check-type 1 [:number])

(adopt/check-type "hello" [:string])

(adopt/check-type nil [:string :nil])

(adopt/check-type good [:string :nil])

(try
  (adopt/check-type good [:number :nil])
  ([err]
   (do
     (assert (> (string/find "failed" err) 0))
     (assert (> (length err) 0)))))


(def verbose-option (adopt/make-option
           @{:name "verbose"
             :short "v"
             :long "verbose"
             :help "Add more verbose output."}))

(adopt/print-object verbose-option)
(loop [key :in (keys verbose-option)]
  (print "  " key ": " (get verbose-option key)))


(print "\nbad option")
(def badoption (adopt/make-option @{:name "badoption"}))

(adopt/exit 0)
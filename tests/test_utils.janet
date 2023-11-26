(use spork/test)
(import ../adopt)

(start-suite 'utils)

(assert (adopt/member 1 @[1 4 5]))
(assert (not (adopt/member 2 @[1 4 5])))

(assert (adopt/member adopt/last-arg @[adopt/first-arg adopt/collect adopt/last-arg]))
(assert (adopt/member adopt/last-arg [adopt/first-arg adopt/collect adopt/last-arg]))

(assert-no-error (adopt/check-type 1 [:number]))

(assert-no-error (adopt/check-type "hello" [:string]))

(assert-no-error (adopt/check-type nil [:string :nil]))

(var good "goodbye")
(assert-no-error (adopt/check-type good [:string :nil]))

(assert-error "good is not :number"
              (adopt/check-type good [:number :nil]))



(end-suite)
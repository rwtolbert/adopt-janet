(use spork/test)

(import ../adopt)

(start-suite 'utils)

(assert (adopt/member 1 @[1 4 5]))
(assert (not (adopt/member 2 @[1 4 5])))

(assert (adopt/member adopt/utils/last-arg @[adopt/utils/first-arg adopt/utils/collect adopt/utils/last-arg]))
(assert (adopt/member adopt/utils/last-arg [adopt/utils/first-arg adopt/utils/collect adopt/utils/last-arg]))

(assert-no-error (adopt/check-type 1 [:number]))

(assert-no-error (adopt/check-type "hello" [:string]))

(assert-no-error (adopt/check-type nil [:string :nil]))

(var good "goodbye")
(assert-no-error (adopt/check-type good [:string :nil]))

(assert-error "good is not :number"
              (adopt/check-type good [:number :nil]))

(assert (adopt/utils/shortp "-v"))
(assert (adopt/utils/shortp "-vvv"))

(assert (adopt/utils/longp "--verbose"))
(assert (not (adopt/utils/longp "-verbose")))
(assert (not (adopt/utils/longp "-vvv")))

(assert (adopt/utils/terminatorp "--"))

(defn test-x [x]
  (when (nil? x)
    (error (fn [y] (string/format "%q is nil" y)))))

(def x nil)

(try
  (test-x x)
  ([e]
   (adopt/utils/handle-error e x)))

(adopt/utils/handle-error (fn [x] (string/format "error val: %q" x)) 42)
(adopt/utils/handle-error 42)

(end-suite)
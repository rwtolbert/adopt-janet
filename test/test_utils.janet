(use spork/test)

(import ../adopt)

(start-suite 'utils)

(assert (adopt/member 1 @[1 4 5]))
(assert (not (adopt/member 2 @[1 4 5])))

(assert (adopt/member adopt/utils/last-arg @[adopt/utils/first-arg adopt/utils/collect adopt/utils/last-arg]))
(assert (adopt/member adopt/utils/last-arg [adopt/utils/first-arg adopt/utils/collect adopt/utils/last-arg]))

(assert-no-error "1 is a number" (adopt/check-type 1 [:number]))

(assert-no-error "'hello' is a string" (adopt/check-type "hello" [:string]))

(assert-no-error "nil is :nil" (adopt/check-type nil [:string :nil]))

(var good "goodbye")
(assert-no-error "good is :number" (adopt/check-type good [:string :nil]))

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

# version
(def info (-> (slurp "./bundle/info.jdn") parse))
(assert (= (info :version) (adopt/version)))

# tests for number parsing

(assert (= (adopt/utils/parse-positive-int "3") 3))
(assert (= (adopt/utils/parse-positive-int "+3") 3))
(assert (not (adopt/utils/parse-positive-int "a")))
(assert (not (adopt/utils/parse-positive-int "-3")))
(assert (not (adopt/utils/parse-positive-int "3.5")))

(assert (= (adopt/utils/parse-int "-3")) -3)
(assert (= (adopt/utils/parse-int "3")) 3)
(assert (= (adopt/utils/parse-int "+3")) 3)
(assert (not (adopt/utils/parse-int "a")))
(assert (not (adopt/utils/parse-int "3.5")))

(assert (= (adopt/utils/parse-float "-3") -3))
(assert (= (adopt/utils/parse-float "-3.5") -3.5))
(assert (= (adopt/utils/parse-float "0.89") 0.89))
(assert (not (adopt/utils/parse-float "a")))
(assert (not (adopt/utils/parse-float "3.a")))

(assert-no-error "3 is a positive int" (adopt/utils/require-positive-int "3"))
(assert-error "-3 is not positive" (adopt/utils/require-positive-int "-3"))
(assert-error "3. is not a positive int" (adopt/utils/require-positive-int "3."))
(assert-error "abc is not an positive int" (adopt/utils/require-positive-int "abc"))

(assert-no-error "3 is an int" (adopt/utils/require-int "3"))
(assert-no-error "-3 is an int" (adopt/utils/require-int "-3"))
(assert-error "3. is not an int" (adopt/utils/require-int "3."))
(assert-error "abc is not an int" (adopt/utils/require-int "abc"))

(assert-no-error "3 is a float" (adopt/utils/require-float "3"))
(assert-no-error "-3 is a float" (adopt/utils/require-float "-3"))
(assert-no-error "3. is a float" (adopt/utils/require-float "3."))
(assert-no-error "3.5 is a float" (adopt/utils/require-float "3.5"))
(assert-no-error "0.658 is a float" (adopt/utils/require-float "0.658"))
(assert-no-error "-0.658 is a float" (adopt/utils/require-float "-0.658"))
(assert-error "abc is not a float" (adopt/utils/require-float "abc"))


(end-suite)

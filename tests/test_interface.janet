(use spork/test)

(import ../adopt)

(start-suite 'interface)

(defn result [&opt key-value-pairs]
  (let [res @[]]
    (if (not (nil? key-value-pairs))
      (loop [[k v] :in (pairs key-value-pairs)]
        (put res k v)))
      res))

(defn split-args [args]
  (adopt/utils/remove-if-empty (string/split " " args)))

(defn check [interface input expected-args expected-results]
  (def $args (gensym))
  (def $results (gensym))
  (def [$args $results]
    (adopt/parse-options interface (split-args input)))
#   (printf "IN %q" input)
#   (printf "OUT %q" $args)
#   (printf "EXPECTED %q\n" expected-args)
  (assert (adopt/utils/array-equal $args expected-args))
  (assert (adopt/utils/hash-table-equal $results expected-results)))

(def *noop*
  (adopt/make-interface
   @{:name "noop"
     :summary "no options"
     :help "this interface has no options"
     :usage ""}))

(check *noop* ""
       @[] 
       (result))

(check *noop* "foo"
       @["foo"]
       (result))

(check *noop* "a b c foo a"
       @["a" "b" "c" "foo" "a"]
       (result))

(end-suite)
(use spork/test)

(import ../adopt)

(start-suite 'interface)

(defn result [&opt & key-value-pairs]
  (let [res @[]]
    (if (not (nil? key-value-pairs))
      (loop [[k v] :in (pairs key-value-pairs)]
        (put res k v)))
      res))

(defn equal [a b]
  (if (= (type a) :array)
    (and (= (length a) (length b))
         (label result
                (do (var count 0)
                    (while (< count (length a))
                      (unless (= (get a count) (get b count))
                        (return result false))
                      (++ count)))
                true))
    (= a b)))

(defn compare-results [results expected-results]
  # (printf "IN RES %q" results) 
  # (printf "IN EXP %q" expected-results)
  (label result
         (while (> (length expected-results) 0)
           (def v (array/pop expected-results))
           (def k (array/pop expected-results))
          #  (printf "COMPARE %q %q %q %q" k v (get results k) (equal (get results k) v))
           (unless (equal (get results k) v)
             (return result nil)))
         true))

(defn split-args [args]
  (adopt/utils/remove-if-empty (string/split " " args)))

(defn check [interface input expected-args expected-results]
  (def $args (gensym))
  (def $results (gensym))
  (def [$args $results]
    (adopt/parse-options interface (split-args input)))
  # (printf "IN %q" input)
  # (printf "OUT %q" $args)
  # (printf "EXPECTED %q\n" expected-args)
  # (printf "EXP RES  %q\n" expected-results)
  # (printf "RESULTS  %q\n" $results)
  (assert (adopt/utils/array-equal $args expected-args))
  (assert (compare-results $results expected-results)))

(defn ct [] (adopt/constantly true))

### setup

(def *noop*
  (adopt/make-interface
   @{:name "noop"
     :summary "no options"
     :help "this interface has no options"
     :usage ""}))


(def *option-types*
  (adopt/make-interface
   @{:name "option-types"
     :summary "testing option types"
     :help "this interface tests both option types"
     :usage "[OPTIONS]"
     :contents
     [(adopt/make-option @{:name 'long
                           :help "long only"
                           :long "long"
                           :reduce (ct)})
      (adopt/make-option @{:name 'short
                           :help "short only"
                           :short "s"
                           :reduce (ct)})
      (adopt/make-option @{:name 'both
                           :help "both short and long"
                           :short "b"
                           :long "both"
                           :reduce (ct)})]}))

(def *reducers*
  (adopt/make-interface
    @{:name "reducers"
    :summary "testing reducers"
    :help "this interface tests basic reducers"
    :usage "[OPTIONS]"
    :contents
    [(adopt/make-option @{:name 'c1
                          :help "1"
                          :short "1"
                          :reduce (adopt/constantly 1)})
     (adopt/make-option @{:name 'c2
                          :help "2"
                          :short "2"
                          :reduce (adopt/constantly 2)})
     (adopt/make-option @{:name 'collect
                          :help "collect"
                          :short "c"
                          :long "collect"
                          :parameter "DATA"
                          :reduce adopt/utils/collect})
     (adopt/make-option @{:name 'last
                          :help "last"
                          :short "l"
                          :long "last"
                          :parameter "DATA"
                          :reduce adopt/utils/last-arg})
     (adopt/make-option @{:name 'first
                          :help "first"
                          :short "f"
                          :long "first"
                          :parameter "DATA"
                          :reduce adopt/utils/first-arg})]}))


(assert (compare-results @{"foo" true} @["foo" true]))

### tests

(check *noop* ""
       @[]
       @[])

(check *noop* "foo"
       @["foo"]
       @[])

(check *noop* "a b c foo a"
       @["a" "b" "c" "foo" "a"]
       @[])

(check *option-types* "foo -s bar"
       ["foo" "bar"]
       @['short true
         'long nil
         'both nil])

(check *option-types* "foo --long bar"
       ["foo" "bar"]
       @['short nil
         'long true
         'both nil]) 

(check *option-types* "foo --both bar"
       ["foo" "bar"]
       @['short nil
        'long nil
         'both true])

(check *option-types* "foo -b bar"
       ["foo" "bar"]
       @['short nil
         'long nil
         'both true]) 

(check *option-types* "foo -bs --long bar"
         ["foo" "bar"]
         @['short true
           'long true
           'both true])

(assert-no-error "this should work"
                 (adopt/make-option @{:name 'foo :reduce (ct) :help "this should work" :short "x"}))
(assert-error "this should not work" 
              (adopt/make-option @{:name 'bar :reduce (ct) :help "this should not work"}))

(check *reducers* ""
       []
       @['c1 nil
         'c2 nil
         'first nil
         'last nil
         'collect nil])

(check *reducers* "here we -2 -2 --collect a -c b go --collect c -1"
       ["here" "we" "go"]
       @['c1 1
         'c2 2
         'first nil
         'last nil
         'collect @["a" "b" "c"]])

(check *reducers* "foo -f 1 -f 2 --last 1 --first 3 --last 2 -l 3 bar"
       ["foo" "bar"]
       @['c1 nil
         'c2 nil
         'first "1"
         'last "3"
         'collect nil])

(end-suite)
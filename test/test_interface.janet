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

(defn array-copy [a b]
  (var idx 0)
  (while (< (length a) (length b))
    (array/push a (get b idx))
    (++ idx)))

(defn compare-results [results expected-results]
  # (printf "IN RES %q" results)
  # (printf "IN EXP %q" expected-results)
  (var res @[])
  (array-copy res expected-results)
  (while (> (length res) 0)
    (def v (array/pop res))
    (def k (array/pop res))
    # (printf "COMPARE %q %q %q %q" k v (get results k) (equal (get results k) v))
    (unless (equal (get results k) v)
      (error (string/format "compare fail: %q != %q" (get results k) v)))))

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
  (assert-no-error (string/format "compare error: %q -> %q == %q"
                                  input $results expected-results)
                   (compare-results $results expected-results)))

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

(def *same-key*
  (adopt/make-interface @{:name "same-key"
                          :summary "testing same keys"
                          :help "this interface tests options with the same result-key"
                          :usage "[OPTIONS]"
                          :contents @[(adopt/make-option @{:name 'a
                                                           :result-key 'foo
                                                           :help "1"
                                                           :short "1"
                                                           :reduce (adopt/constantly 1)})
                                      (adopt/make-option @{:name 'b
                                                           :result-key 'foo
                                                           :help "2"
                                                           :short "2"
                                                           :reduce (adopt/constantly 2)})]}))

(def *initial-value*
  (adopt/make-interface @{:name "initial-value"
                          :summary "testing initial values"
                          :help "this interface tests the initial-value argument"
                          :usage "[OPTIONS]"
                          :contents
                          @[(adopt/make-option @{:name 'foo
                                                 :help "foo"
                                                 :short "f"
                                                 :long "foo"
                                                 :initial-value "hello"
                                                 :reduce (adopt/constantly "goodbye")})]}))

(def *key*
  (adopt/make-interface @{:name "key"
                          :summary "testing key"
                          :help "this interface tests the key argument"
                          :usage "[OPTIONS]"
                          :contents @[(adopt/make-option @{:name 'int
                                                           :help "int"
                                                           :short "i"
                                                           :long "int"
                                                           :parameter "K"
                                                           :reduce adopt/utils/collect
                                                           :key scan-number})
                                      (adopt/make-option @{:name 'len
                                                           :help "len"
                                                           :short "l"
                                                           :long "len"
                                                           :parameter "K"
                                                           :reduce adopt/utils/collect
                                                           :key length})]}))

(defn toupper [a]
  (printf "input %q" a)
  (string/ascii-upper a))


(def *finally*
  (adopt/make-interface @{:name "finally"
                          :summary "testing finally"
                          :help "this interface tests the finally argument"
                          :usage "[OPTIONS]"
                          :contents
                          @[(adopt/make-option @{:name 'yell
                                                 :help "yell"
                                                 :short "y"
                                                 :long "yell"
                                                 :parameter "VAL"
                                                 :initial-value "default"
                                                 :reduce adopt/utils/last-arg
                                                 :finally string/ascii-upper})
                            (adopt/make-option @{:name 'a
                                                 :help "ensure a"
                                                 :short "a"
                                                 :initial-value "x"
                                                 :parameter "A"
                                                 :reduce adopt/utils/last-arg
                                                 :finally (fn [a] (assert (= "a" a)) :ok)})]}))


(def [*bool* *no-bool*]
  (adopt/make-boolean-options
    @{:name 'bool
      :long "bool"
      :short "b"
      :help "Bool yes."
      :help-no "Bool no."}))

(def *bools*
  (adopt/make-interface @{:name "bools"
                          :summary "testing boolean options"
                          :help "this interface tests booleans"
                          :usage "[OPTIONS]"
                          :contents @[*bool* *no-bool*]}))

(assert-no-error "checking compare results"
                 (compare-results @{"foo" true} @["foo" true]))

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

(check *same-key* ""
       []
       @['x nil])
(check *same-key* "-1"
       []
       @['foo 1])
(check *same-key* "-2"
       []
       @['foo 2])
(check *same-key* "-1121"
       []
       @['foo 1])

(check *initial-value* ""
       []
       @['foo "hello"])

(check *initial-value* "x"
       ["x"]
       @['foo "hello"])

(check *initial-value* "x --foo y"
       ["x" "y"]
       @['foo "goodbye"])

(check *key* ""
       []
       @[])

(check *key* "--int 123 --int 0 --len abc --len 123456"
       []
       @['int [123 0]
         'len [3 6]])

(check *finally* "-a a"
       []
       @['yell "DEFAULT" 'a :ok])

(check *finally* "-y foo -y bar -a x -a a"
       []
       @['yell "BAR" 'a :ok])

(check *bools* "" [] @['bool nil])
(check *bools* "--bool" [] @['bool true])
(check *bools* "--bool --no-bool" [] @['bool false])
(check *bools* "-b" [] @['bool true])
(check *bools* "-b -B" [] @['bool false])


# make sure an option with a parameter fails to parse if it is missing

(def *has-parameter*
  (adopt/make-interface
    @{:name "has-parameter"
      :summary "has parameter"
      :usage "foo"
      :help "foo"
      :contents [(adopt/make-option @{:name 'depth
                                      :help "depth"
                                      :long "depth"
                                      :short "d"
                                      :parameter "DEPTH"
                                      :reduce adopt/utils/first-arg})]}))

(assert-error "short option with parameter needs a value"
              (def [a b] (adopt/parse-options *has-parameter* (split-args "-d"))))

(assert-error "long option with parameter needs a value"
              (def [a b] (adopt/parse-options *has-parameter* (split-args "--depth"))))

(assert-no-error "short option has parameter"
                 (def [a b] (adopt/parse-options *has-parameter* (split-args "-d 5")))
                 (assert (= (b 'depth) "5")))

(assert-no-error "short option has parameter"
                 (def [a b] (adopt/parse-options *has-parameter* (split-args "--depth 5")))
                 (assert (= (b 'depth) "5")))

# (print "***** PARAMETER")
# (printf "%q" a)
# (printf "%q" b)

(assert (equal :old (adopt/utils/first-arg :old :new)))
(assert (equal :new (adopt/utils/last-arg :old :new)))
(assert (equal @[:a] (adopt/utils/collect @[] :a)))
(assert (equal @[:a :b] (adopt/utils/collect @[:a] :b)))

# usage as single string
(assert-no-error
  (adopt/make-interface @{:name ""
                          :summary ""
                          :help ""
                          :usage "[options] arg"
                          :contents @[(adopt/make-option @{:name 'foo
                                                           :reduce (ct)
                                                           :help ""
                                                           :short "a"
                                                           :long "foo"})
                                      (adopt/make-option @{:name 'bar
                                                           :reduce (ct)
                                                           :help ""
                                                           :short "b"
                                                           :long "bar"})]}))

# usage as vector
(assert-no-error
  (adopt/make-interface @{:name ""
                          :summary ""
                          :help ""
                          :usage ["[options] arg" "-h"]
                          :contents @[(adopt/make-option @{:name 'foo
                                                           :reduce (ct)
                                                           :help ""
                                                           :short "a"
                                                           :long "foo"})
                                      (adopt/make-option @{:name 'bar
                                                           :reduce (ct)
                                                           :help ""
                                                           :short "b"
                                                           :long "bar"})]}))

(assert-error "duplicate short option"
              (adopt/make-interface @{:name ""
                                      :summary ""
                                      :help ""
                                      :usage ""
                                      :contents @[(adopt/make-option @{:name 'foo
                                                                       :reduce (ct)
                                                                       :help ""
                                                                       :short "a"
                                                                       :long "foo"})
                                                  (adopt/make-option @{:name 'bar
                                                                       :reduce (ct)
                                                                       :help ""
                                                                       :short "a"
                                                                       :long "bar"})]}))
(assert-error "duplicate long option"
              (adopt/make-interface @{:name ""
                                      :summary ""
                                      :help ""
                                      :usage ""
                                      :contents @[(adopt/make-option @{:name 'foo
                                                                       :reduce (ct)
                                                                       :help ""
                                                                       :short "a"
                                                                       :long "oops"})
                                                  (adopt/make-option @{:name 'bar
                                                                       :reduce (ct)
                                                                       :help ""
                                                                       :short "b"
                                                                       :long "oops"})]}))

# single/multiple usage
(def single-usage
  (adopt/make-interface @{:name "single"
                          :summary "single-usage"
                          :help "This is some help"
                          :usage "[options] arg"
                          :examples @[["do foo" "single --foo"]]
                          :contents @[(adopt/make-option @{:name 'foo
                                                           :reduce (ct)
                                                           :help "Set foo"
                                                           :short "a"
                                                           :long "foo"})
                                      (adopt/make-option @{:name 'bar
                                                           :reduce (ct)
                                                           :help "Set bar"
                                                           :short "b"
                                                           :long "bar"})]}))
(adopt/print-help single-usage :program-name "single")

(def multi-usage
  (adopt/make-interface @{:name "multi"
                          :summary "multi-usage"
                          :help "This is some help"
                          :usage ["[options] arg" "(-h | --help)"]
                          :contents @[(adopt/make-option @{:name 'foo
                                                           :reduce (ct)
                                                           :help "Set foo"
                                                           :short "a"
                                                           :long "foo"})
                                      (adopt/make-option @{:name 'bar
                                                           :reduce (ct)
                                                           :help "Set bar"
                                                           :short "b"
                                                           :long "bar"})]}))

(adopt/print-help multi-usage :program-name "multi")


(end-suite)

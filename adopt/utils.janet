(defn maphash [func tbl]
  (loop [[k v] :in (pairs tbl)]
    ((func k v))))

(defn maphashcat [func tbl]
  (let [results @[]]
    (loop [[k v] :in (pairs tbl)]
      (array/push results (func k v)))
    results))

(defn hash-table-equal [h1 h2]
  (and (= (length h1)
          (length h2))
       (label result
         (maphash (fn [k v]
                    (unless (= v (get h2 k))
                      (return result nil)))
                  h1)
         true)))

(defn array-equal [a1 a2]
  (and (= (length a1)
          (length a2))
       (label result
         (var i 0)
         (while (< i (length a1))
           (unless (= (get a1 i) (get a2 i))
             (return result nil))
           (++ i))
         true)))

(defn collect (arr el)
  "Append element `el` to the end of `arr`.

  It is useful as a `:reduce` function when you want to collect all values given
  for an option.

  "
  (if (= (type arr) :array)
    (array/push arr el)
    (let [result @[]]
      (when (not (nil? arr))
        (array/push result arr))
      (array/push result el))))


(defn first-arg
  "Return `new` if `old` is `nil`, otherwise return `old`.

  It is useful as a `:reduce` function when you want to just keep the
  first-given value for an option.

  "
  [old new]
  (if (nil? old)
    new
    old))


(defn last-arg (old new)
  "Return `new`.

  It is useful as a `:reduce` function when you want to just keep the last-given
  value for an option.

  "
  new)

(defn remove-if-empty [list]
  (let [results @[]]
    (seq [item :in list]
      (unless (= item "")
        (array/push results item)))
    results))

(defn remove-nil [list]
  (let [results @[]]
    (seq [item :in list]
      (unless (nil? item)
        (array/push results item)))
    results))

(defn has-key [table key]
  "Check if 'key' is in 'table"
  (not (nil? (table key))))

(defn shortp [arg]
  "Validate a short arg, can be -x or -vvvv"
  (and (> (length arg) 1)
       (= (string/slice arg 0 1) "-")
       (not (string/find "-" (string/slice arg 1 (length arg))))))

(defn longp [arg]
  "Validate a long arg like --verbose"
  (and (> (length arg) 2)
       (= (string/slice arg 0 1) "-")
       (= (string/slice arg 1 2) "-")))

(defn terminatorp [arg]
  "Validate the special terminator arg '--'"
  (= "--" arg))

(defn exit
  "Exit the program with status `code`."
  [&opt code]
  (default code 0)
  (os/exit code))

(defn handle-error (e &opt x)
  (match (type e)
    :string (print e)
    :function (print (e x))
    _ (printf "unknown error type %q" (type e))))

(defn handle-error-and-exit (e &opt x)
  (handle-error e x)
  (exit 1))

############################
# some methods to coerce arguments into numeric values

(def- *positive-int-peg* (peg/compile '(number (* 0 (? "+") :d+ -1))))
(def- *int-peg* (peg/compile '(number (* 0 (any (+ "+" "-")) :d+ -1))))
(def- *float-peg* (peg/compile '(number (* 0 (any (+ "+" "-")) :d+ (any (+ "." :d+)) -1))))

(defn- parse-number [patt x]
  (let [input (case (type x)
                :number (string/format "%q" x)
                :string x)
        matches (peg/match patt input)]
    (when matches
      (matches 0))))

(defn parse-positive-int [x]
  (parse-number *positive-int-peg* x))

(defn parse-int [x]
  (parse-number *int-peg* x))

(defn parse-float [x]
  (parse-number *float-peg* x))

(defn- require-number [func x msg &opt name]
  (default name "option")
  (let [val (func x)]
    (when (nil? val)
      (error (string/format "%s requires a %s value, '%V' given" name msg x)))
    val))

(defn require-positive-int [x &opt name]
  (require-number parse-positive-int x "positive integer" name))

(defn require-int [x &opt name]
  (require-number parse-int x "integer" name))

(defn require-float [x &opt name]
  (require-number parse-float x "float" name))

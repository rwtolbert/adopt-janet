(import ./utils :export true)

(defn- add2
  "Sum two numbers"
  [x y]
  (+ x y))

(defn argv
  "Return a list of the program name and command line arguments.

  "
  []
  (dyn :args))

(defn exit
  "Exit the program with status `code`."
  [&opt code]
  (default code 0)
  (os/exit code))

# (defn error
#   "emit message and exit"
#   [msg]
#   (print "Error: " msg)
#   (exit 1))


(defn print-object
  "Print an option/parameter"
  [obj]
  (print (string/format "%s %s/%s" (get obj :name) (get obj :short) (get obj :long))))


(defn member
  "Check if item is in arr"
  [item arr]
  (var result false)
  (each i arr
    # (print "  item " item ",  i " i)
    (when (= i item)
      (set result true)))
  result)


(defmacro check-type [place types]
  (def $type (gensym))
  ~(let [$type (type ,place)]
    #  (print "check-type place " ,place " " ,(type place) " $t " $type " " (type $type))
     (if (not (,member $type ,types))
       (error (string/format "'%q (%q)' failed check-type" ,place $type)))))

(defn to-pairs [arr]
  "Convert array into array of pairs"
  (assert (even? (length arr)))
  (def len (length arr))
  (var i 0)
  (var result @[])
  (while (< i len)
    (array/push result [(get arr i) (get arr (+ i 1))])
    (set i (+ i 2)))
  # (print "result " result " len " (length result))
  result)

# (defmacro check-types
#   "Check all the types"
#   [& place-type-pairs]
#   (loop [part :in (to-pairs place-type-pairs)]
#     ~(print "\ninput pair " ,(first part) " " ,(type (first part)))
#     ~(check-type (first part) (last part))))

# (defmacro check-types (&rest check-type-pairs)
#   ~(each () check-type-pairs)
#   )



(defn make-option
  "Create and return an option, suitable for use in an interface.

  This function takes a number of arguments, some required, that define how the
  option interacts with the user.

  * `:name` (**required**): a symbol naming the option.
  * `:help` (**required**): a short string describing what the option does.
  * `:result-key` (optional): a symbol to use as the key for this option in the hash table of results.
  * `:long` (optional): a string for the long form of the option (e.g. `--foo`).
  * `:short` (optional): a character for the short form of the option (e.g. `-f`).  At least one of `short` and `long` must be given.
  * `:manual` (optional): a string to use in place of `help` when rendering a man page.
  * `:parameter` (optional): a string.  If given, it will turn this option into a parameter-taking option (e.g. `--foo=bar`) and will be used as a placeholder
  in the help text.
  * `:reduce` (**required**): a function designator that will be called every time the option is specified by the user.
  * `:initial-value` (optional): a value to use as the initial value of the option.
  * `:key` (optional): a function designator, only allowed for parameter-taking options, to be called on the values given by the user before they are passed along to the reducing function.  It will not be called on the initial value.
  * `:finally` (optional): a function designator to be called on the final result after all parsing is complete. 

  The manner in which the reducer is called depends on whether the option takes a parameter:

  * For options that don't take parameters, it will be called with the old value.
  * For options that take parameters, it will be called with the old value and the value given by the user.

  See the full documentation for more information.

  "
  [{:name name
    :help help
    :result-key result-key
    :long long
    :short short
    :manual manual 
    :parameter parameter
    :reduce reducer
    :initial-value initial-value
    :key key
    :finally finally}]
  (default name nil)
  (default help nil)
  (default result-key nil)
  (default long nil)
  (default short nil)
  (default manual nil)
  (default parameter nil)
  (default reducer nil)
  (default initial-value nil)
  (default key nil)
  (default finally nil)
  (when (nil? name)
    (error (string/format "make-option requires :name")))
  (when (nil? help)
    (error (string/format "make-option for '%s' requires :help" name)))
  # (when (nil? reducer)
  #   (error (string/format "Option %s requires :reducer" name)))
  (when (and (nil? short) (nil? long))
    (error (string/format "Option %s requires one of :short/:long" name)))
  (when (and (member reducer @[utils/collect utils/first-arg utils/last-arg])
             (nil? parameter))
    (error (string/format "Option %s has reducer function %s, which requires a :parameter."
                          name reducer)))
  (check-type long [:string :nil])
  (check-type short [:string :nil])
  (check-type help [:string])
  (check-type manual [:string :nil])
  (check-type parameter [:string :nil])
  @{:name name
    :help help
    :result-key result-key
    :long long
    :short short
    :manual manual
    :parameter parameter
    :reduce reducer
    :initial-value initial-value
    :key key
    :finally finally})
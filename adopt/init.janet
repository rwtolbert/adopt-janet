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


(defn print-option
  "Print an option/parameter"
  [obj]
  (def l (get obj :long))
  (def s (get obj :short))
  (if (and l s)
    (printf "%s: -%s/--%s" (get obj :name) s l)
    (do (when (not (nil? l))
          (printf "%s: --%s" (get obj :name) l))
        (when (not (nil? s))
          (printf "%s: -%s" (get obj :name) s)))))


(defn print-group
  "Print a group of options"
  [group]
  (printf "%s (%d options)" (group :name) (length (group :options))))


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
  result)

# (defmacro check-types)
#   "Check all the types"
#   [& place-type-pairs]
#   (loop [part :in (to-pairs place-type-pairs)])
#     ~(print "\ninput pair " ,(first part) " " ,(type (first part)))
#     ~(check-type (first part) (last part))


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
  (default result-key name)
  (default long nil)
  (default short nil)
  (default manual nil)
  (default parameter nil)
  (default reducer nil)
  (default initial-value nil)
  (default key identity)
  (default finally identity)
  (when (nil? name)
    (error (string/format "make-option requires :name")))
  (when (nil? help)
    (error (string/format "make-option for '%s' requires :help" name)))
  (when (nil? reducer)
    (error (string/format "Option %s requires :reducer" name)))
  (when (and (nil? short) (nil? long))
    (error (string/format "Option %s requires one of :short/:long" name)))
  (when (and (member reducer @[utils/collect utils/first-arg utils/last-arg])
             (nil? parameter))
    (error (string/format "Option '%s' has reducer function, which requires a :parameter."
                          name)))
  (check-type name [:symbol])
  (check-type long [:string :nil])
  (check-type short [:string :nil])
  (check-type help [:string])
  (check-type manual [:string :nil])
  (check-type parameter [:string :nil])
  (check-type reducer [:function :cfunction :nil])
  (check-type finally [:function :cfunction :nil])
  (check-type key [:function :cfunction :nil])
  @{:type 'option
    :name name
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


(defn is-option [object]
  (= (object :type) 'option))


(defn constantly [object]
  (fn [x &] object))


(defn make-boolean-options
  "Create and return a pair of boolean options, suitable for use in an interface.

  This function reduces some of the boilerplate when creating two `option`s for
  boolean values, e.g. `--foo` and `--no-foo`.  It will try to guess at an
  appropriate name, long option, short option, and result key, but you can
  override them with the `…-no` keyword options as needed.

  The two options will be returned as two separate values — you can use
  `def` to conveniently bind them to two separate variables if
  desired.

  Example:

    (def [*option-debug* *option-no-debug*]
      (make-boolean-options 'debug
        :long \"debug\"
        :short \"d\"
        :help \"Enable the debugger.\"
        :help-no \"Disable the debugger (the default).\"))

    ;; is roughly equivalent to:

    (def *option-debug*
      (make-option 'debug
        :long \"debug\"
        :short \"d\"
        :help \"Enable the debugger.\"
        :initial-value nil
        :reduce (constantly t))

    (def *option-no-debug*
      (make-option 'no-debug
        :long \"no-debug\"
        :short \"D\"
        :help \"Disable the debugger (the default).\"
        :reduce (constantly nil))

  "
  [{:name name
    :key key
    :name-no name-no
    :long long
    :long-no long-no
    :short short
    :short-no short-no
    :help help
    :help-no help-no
    :manual manual
    :manual-no manual-no}]
  (default name-no (symbol "no-" name))
  (default long-no (when long (string/format "no-%s" long)))
  (default short-no (when short (string/ascii-upper short)))
  [(make-option @{:name name
                  :result-key name
                  :long long
                  :short short
                  :help help
                  :manual manual
                  :initial-value nil
                  :reduce (constantly true)})
   (make-option @{:name name-no
                  :result-key name
                  :long long-no
                  :short short-no
                  :help help-no
                  :manual manual-no
                  :reduce (constantly nil)})])

(defn make-group
  "Create and return an option group, suitable for use in an interface.

  This function takes a number of arguments that define how the group is
  presented to the user:

  * `name` (**required**): a symbol naming the group.
  * `options` (**required**): the options to include in the group.
  * `title` (optional): a title for the group for use in the help text.
  * `help` (optional): a short summary of this group of options for use in the help text.
  * `manual` (optional): used in place of `help` when rendering a man page.

  See the full documentation for more information.
  "
  [{:name name
    :key key
    :options options
    :title title
    :help help
    :manual manual}]
  (default title nil)
  (default help nil)
  (default manual nil)
  (check-type name [:symbol])
  (check-type title [:string :nil])
  (check-type help [:string :nil])
  (check-type manual [:string :nil])
  (check-type options [:array :tuple])
  @{:type 'group
    :name name
    :title title
    :help help
    :manual manual
    :options options})

(defn is-group [object] (= (object :type) 'group))

(defn make-default-group [options]
  (make-group @{:name 'default :options options}))


(defn make-interface
  "Create and return a command line interface.

  This function takes a number of arguments that define how the interface is
  presented to the user:

  * `name` (**required**): a symbol naming the interface.
  * `summary` (**required**): a string of a concise, one-line summary of what the program does.
  * `usage` (**required**): a string of a UNIX-style usage summary, e.g. `\"[OPTIONS] PATTERN [FILE...]\"`.
  * `help` (**required**): a string of a longer description of the program.
  * `manual` (optional): a string to use in place of `help` when rendering a man page.
  * `examples` (optional): an alist of `(prose . command)` conses to render as a list of examples.
  * `contents` (optional): a list of options and groups.  Ungrouped options will be collected into a single top-level group.

  See the full documentation for more information.

  "
  [@{:name name
     :summary summary
     :usage usage
     :help help
     :manual manual
     :examples examples
     :contents contents}]
  (default manual nil)
  (default examples @[])
  (default contents @[])
  (check-type name [:string])
  (check-type summary [:string])
  (check-type usage [:string])
  (check-type help [:string])
  (check-type manual [:manual :nil])
  (check-type examples [:array :tuple])
  (check-type contents [:array :tuple])
  (let [ungrouped-options (filter is-option contents)
        groups (let
                [grps @((make-default-group ungrouped-options))]
                 (seq [opt :in contents]
                   (when (is-group opt)
                     (array/push grps opt)))
                 grps)
        options (flatten (seq [g :in groups] (g :options)))
        interface @{:name name
                    :usage usage
                    :summary summary
                    :help help
                    :manual manual
                    :examples examples
                    :groups groups
                    :options options
                    :short-options @{}
                    :long-options @{}}
        add-option (fn [option]
                     (let [short (option :short)
                           long (option :long)]
                       (when short
                         (when (utils/has-key (interface :short-options) short)
                           (error (string/format "Duplicate short-option %s." short)))
                         (put (interface :short-options) short option))
                       (when long
                         (when (utils/has-key (interface :long-options) long)
                           (error (string/format "Duplicate long-option %s." long)))
                         (put (interface :long-options) long option))))]
    (seq [g :in groups]
      (map add-option (g :options)))
    interface))

# parsing options from args
(defn initialize-results [interface results]
  # (printf "OPTIONS %q" (interface :options))
  (seq [option :in (interface :options)]
    (if (not (nil? (option :initial-value)))
      (put results (option :result-key) (option :initial-value))
      (put results (option :result-key) nil))))

(defn finalize-results [interface results]
  (seq [option :in (interface :options)]
    (when (not (nil? (option :finally)))
      (let [orig (results (option :result-key))
            final ((option :finally) orig)]
        (put results (option :result-key) final)))))

(defn parse-short [interface results arg remaining]
  # (printf "interface %q" (interface :short-options))
  (let [short-name (string/slice arg 1 2)
        option (get (interface :short-options) short-name)]
    # (printf "parse-short %q" short-name)
    (when (nil? option)
      (error (string/format "Problematic option %s" arg)))
    (let [k (option :result-key)
          current (results k)]
      # (printf "option result-key: %q" k)
      # (printf "current results: %q" results)
      (put results k
           (if (option :parameter)
             (let [param ((option :key) (if (> (length arg) 2)
                                          (string/slice arg 2)    # case of -xfoo
                                          (array/pop remaining)))] # case of -x foo 
              #  (printf "   param value: %q" param)
               ((option :reduce) current param))
             (do
               (when (> (length arg) 2)
                #  (printf "LEFT %q" (string/format "-%s" (string/slice arg 2)))
                 (array/push remaining (string/format "-%s" (string/slice arg 2))))
               ((option :reduce) current))))))
    # (printf "RESULTS %q" results)
    # (printf "REMAINING: %q" remaining)
    remaining)


(defn parse-long [interface results arg remaining]
  (let [pos (string/find "=" arg)
        long-name (string/slice arg 2 pos)
        option (get (interface :long-options) long-name)]
    (when (nil? option)
      (error (string/format "Problematic option %s" arg)))
    (let [k (option :result-key)
          current (results k)]
      # (printf "option result-key: %q" k)
      # (printf "current results: %q" results)
      (put results k
           (if (option :parameter)
             (let [param ((option :key) (if pos
                                          (string/slice arg (inc pos))
                                          (array/pop remaining)))]
              #  (printf "   param value: %q" param)
               ((option :reduce) current param))
             ((option :reduce) current)))))
  # (printf "RESULTS %q" results)
  # (printf "REMAINING: %q" remaining)
  remaining)


(defn parse-options [interface &opt args]
  (default args [])
  (let [toplevel @[]
        remaining (reverse (flatten args))
        results @{}]
    (initialize-results interface results)
    # (printf "REMAINING %q" remaining)
    (while (> (length remaining) 0)
      (def arg (array/pop remaining))
      # (print "arg " arg " " (length remaining))
      (try
        (cond
          (utils/terminatorp arg) (do
                                    (seq [a :in remaining]
                                      (array/push toplevel a))
                                    (array/clear remaining))
          (utils/shortp arg) (parse-short interface results arg remaining)
          (utils/longp arg) (parse-long interface results arg remaining)
          (array/push toplevel arg))
        ([e] (error e))))
    (reverse toplevel)
    # (printf "toplevel stuff: %q" toplevel)
    (finalize-results interface results)
    [toplevel results]))


(defn parse-options-or-exit [interface & args]
  (try
    (parse-options interface args)
    ([e] (do
           (printf "error: %q" e)
           (utils/exit 1)))))

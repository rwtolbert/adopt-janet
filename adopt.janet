
(defn add2
  "Sum two numbers"
  [x y]
  (+ x y))

(defn first-of
  "Return `new` if `old` is `nil`, otherwise return `old`.

  It is useful as a `:reduce` function when you want to just keep the
  first-given value for an option.

  "
  [old new]
  (if (nil? old)
    new
    old))

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

(defn error
  "emit message and exit"
  [msg]
  (print "Error: " msg)
  (exit 1))

(defn print-object
  "Print an option/parameter"
  [obj]
  (print (string/format "%s %s/%s" (get obj :name) (get obj :short) (get obj :long))))

(defn make-option
  "Make a default 'option' table"
  [{:name name
    :result-key result-key
    :help help
    :manual manual
    :short short
    :long long}]
  (default name "temp")
  (default result-key "key")
  (default help "this is help")
  (default manual "manual")
  (default short nil)
  (default long nil)
  (when (and (nil? short) (nil? long))
    (error (string/format "Option %s requires one of :short/:long" name)))
  @{:name name
    :result-key result-key
    :help help
    :manual manual
    :short short
    :long long}
  )
(defn collect (arr el)
  "Append element `el` to the end of `arr`.

  It is useful as a `:reduce` function when you want to collect all values given
  for an option.

  "
  (array/push arr el))


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
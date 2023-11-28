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


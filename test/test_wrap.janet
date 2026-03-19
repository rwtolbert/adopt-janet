(use spork/test)

(import ../adopt)

(start-suite 'utils)

(def man-text ``PATTERN can be a regex or a PEG

By default, PATTERN is parsed as a regex and used to match each file line-by-line. Passing
a file that ends in .jdn and/or using the --peg command line flag will interpret the PATTERN
as a Janet PEG (https://janet-lang.org/docs/peg.html).

To use PATTERN as a string literal, and
not parse as a regex, use the '-F/--fixed-strings' flag.

``)

(print "-------------")
(print (adopt/wrap-help man-text))
(print "-------------")

(print "-------------")
(print (adopt/split-paragraphs man-text))
(print "-------------")


(end-suite)

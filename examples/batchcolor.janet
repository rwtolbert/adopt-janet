(import ../adopt)
(import jre)

(def *option-help*
  (adopt/make-option @{:name 'help
                       :help "Display help and exit."
                       :long "help"
                       :short "h"
                       :reduce (adopt/constantly true)}))

(def *option-ignorecase*
  (adopt/make-option @{:name 'ignorecase
                       :help "Ignore case when matching REGEX."
                       :long "ignorecase"
                       :short "i"
                       :reduce (adopt/constantly true)}))

(def [*option-debug* *option-no-debug*]
  (adopt/make-boolean-options @{:name 'debug
                                :long "debug"
                                :short "d"
                                :help "Enable the Janet debugger."
                                :help-no "Disable the Janet debugger (the default)."}))

(def [*option-randomize* *option-no-randomize*]
  (adopt/make-boolean-options @{:name 'randomize
                                :help "Randomize the choice of color each run."
                                :help-no "Do not randomize the choice of color each run (the default)."
                                :long "randomize"
                                :short "r"}))

(def [*option-dark* *option-light*]
  (adopt/make-boolean-options @{:name 'dark
                                :name-no 'light
                                :long "dark"
                                :long-no "light"
                                :help "Optimize for dark terminals (the default)."
                                :help-no "Optimize for light terminals."
                                :initial-value true})) 

(def parse-explicit (jre/compile "^([0-5]),([0-5]),([0-5]):(.+)$"))

(defn match-explicit [arg]
  (let [res (jre/match parse-explicit arg)]
    (if res
      (let [[_ r g b str] (res :groups)]
        [(scan-number r) (scan-number g) (scan-number b) str])
      (do
        (printf "explict should be in the format R,G,B:string")
        (os/exit 0)))))

# (printf "%q" (match-explicit "3,5,0:hello"))

(def *option-explicit*
  (adopt/make-option @{:name 'explicit
                       :parameter "R,G,B:STRING"
                       :help "Highlight STRING in an explicit color.  May be given multiple times."
                       :manual ``Highlight STRING in an explicit color instead of randomly choosing one.
R, G, and B must be 0-5.  STRING is treated as literal string, not a regex.
Note that this doesn't automatically add STRING to the overall regex, you
must do that yourself!  This is a known bug that may be fixed in the future.``
                       :long "explicit"
                       :short "e"
                       :key match-explicit
                       :reduce adopt/utils/collect}))

(def *help-text* ``batchcolor takes a regular expression and matches it against standard 
input one line at a time.  Each unique match is highlighted in its own color. 

If the regular expression contains any capturing groups, only those parts of 
the matches will be highlighted.  Otherwise the entire match will be 
highlighted.  Overlapping capturing groups are not supported.``)

(def *extra-manual-text* 
  ``If no FILEs are given, standard input will be used.  A file of - stands for 
standard input as well. 

Overlapping capturing groups are not supported because it's not clear what ~ 
the result should be.  For example: what should ((f)oo|(b)oo) highlight when ~ 
matched against 'foo'?  Should it highlight 'foo' in one color?  The 'f' in ~ 
one color and 'oo' in another color?  Should that 'oo' be the same color as ~ 
the 'oo' in 'boo' even though the overall match was different?  There are too ~ 
many possible behaviors and no clear winner, so batchcolor disallows ~ 
overlapping capturing groups entirely.``)

(def *examples* @[["Colorize IRC nicknames in a chat log:"
                   "cat channel.log | batchcolor '<(\\\\w+)>'"]
                  ["Colorize UUIDs in a request log:"
                   "tail -f /var/log/foo | batchcolor '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'"]
                  ["Colorize some keywords explicitly and IPv4 addresses randomly (note that the keywords have to be in the main regex too, not just in the -e options):"
                   "batchcolor 'WARN|INFO|ERR|(?:[0-9]{1,3}\\\\.){3}[0-9]{1,3}' -e '5,0,0:ERR' -e '5,4,0:WARN' -e '2,2,5:INFO' foo.log"]
                  ["Colorize earmuffed symbols in a Janet file:"
                   "batchcolor '(?:^|[^*])([*][-a-zA-Z0-9]+[*])(?:$|[^*])' tests/test.janet"]])

(def *ui* (adopt/make-interface @{:name "batchcolor"
                                  :usage "[OPTIONS] REGEX [FILE...]"
                                  :summary "colorize regex matches in batches"
                                  :help *help-text*
                                  :manual (string/format "%s\n\n%s" *help-text* *extra-manual-text*)
                                  :examples *examples*
                                  :contents @[*option-help*
                                              *option-ignorecase*
                                              *option-debug*
                                              *option-no-debug*
                                              (adopt/make-group @{:name 'color-options
                                                                  :title "Color Options"
                                                                  :options @[*option-randomize*
                                                                             *option-no-randomize*
                                                                             *option-dark*
                                                                             *option-light*
                                                                             *option-explicit*]})]}))

(defn main [&]
  (let [[arguments options] (adopt/parse-options-or-exit *ui* (adopt/argv))]
    (cond
      (< (length arguments) 3) (adopt/print-help-and-exit *ui* :exit-code 0)
      (options 'help) (adopt/print-help-and-exit *ui*)
      true (let [pattern (get arguments 1)
                 files (array/slice arguments 2)]
             (printf "pattern %s" pattern)
             (printf "files: %q" files)
             (printf "options %q" options)))))
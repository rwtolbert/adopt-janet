(declare-project
  :name "adopt"
  :description "Janet port of Adopt CL arg processor from https://github.com/sjl/adopt"
  :author "Bob Tolbert"
  :license "MIT"
  :version "0.1.4"
  :url "https://github.com/rwtolbert/adopt-janet"
  :repo "git+https://github.com/rwtolbert/adopt-janet.git"
  :dependencies [{:url "https://github.com/janet-lang/spork.git"}
                 {:url "git@github.com:rwtolbert/re-janet.git" :tag "0.3.1"}])

(declare-source
  :source @["adopt"])

(def info (-> (slurp "./bundle/info.jdn") parse))

(declare-project
  :name (info :name)
  :description (info :description)
  :author (info :author)
  :license (info :license)
  :version (info :version)
  :url (info :url)
  :repo (info :repo)
  :dependencies (info :jpm-dependencies))

(declare-source
  :source @["adopt"])

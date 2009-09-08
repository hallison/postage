require 'rdoc'
require 'rake/rdoctask'

Rake::RDocTask.new("doc:api") do |rdoc|
  rdoc.title    = "Postage - A lightweight API to write post files"
  rdoc.main     = "README"
  rdoc.options  = [ '-SHN', '-f', 'darkfish' ]
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include(
    "AUTHORS",
    "CHANGES",
    "LICENSE",
    "README",
    "lib/**/*.rb"
  )
end


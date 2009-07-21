require 'rdoc'
require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.title    = "Postage"
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


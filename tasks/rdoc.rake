require 'rdoc'
require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.title    = "Postage"
  rdoc.main     = "README"
  rdoc.options  = [ '-SHN', '-f', 'darkfish' ]
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include(
    "AUTHORS",
    "CHANGES",
    "LICENSE",
    "README",
    "lib/**/*.rb"
  )
end


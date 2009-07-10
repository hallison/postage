$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'lib/postage'

Dir["tasks/**.rake"].each do |task_file|
  load task_file
end

task :default => [ :test ]


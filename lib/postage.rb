# Copyright (c) 2009, Hallison Vasconcelos Batista
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Main module for API.
module Postage

  %w(rubygems maruku erb).map do |dependency|
    require dependency
  end

  %w(ruby-debug).map do |optional|
    require optional
  end

  # Root directory for references library.
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  INFO = YAML.load_file(File.join(ROOT, "INFO"))

  # Postage core extensions.
  require 'extensions'

  # Auto-load all libraries
  autoload :Post,   'postage/post'
  autoload :Finder, 'postage/finder'

  class << self

    # Returns the module formatted name.
    def to_s
      "#{INFO[:name]} v#{INFO[:version]} (#{INFO[:cycle]})"
    end
    alias :info :to_s

  end

end # module Postage


# Copyright (c) 2009, Hallison Vasconcelos Batista
# 
# Author:: Hallison Batista <email@hallisonbatista.com>
# 
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Main module for API.
module Postage

  # Root directory for references library.
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  %w(rubygems maruku erb).map do |dependency|
    require dependency
  end

  %w(ruby-debug).map do |optional|
    require optional
  end

  # Postage core extensions.
  require 'extensions'

  # Auto-load all libraries
  autoload :Post,   'postage/post'
  autoload :Finder, 'postage/finder'

  class << self

    # Project version.
    def version
      "0.1.0"
    end

    # Tagged for development cycle.
    def cycle
      "Development release - Pre-alpha"
    end

    # Returns the module formatted name.
    def to_s
      "#{self.name} v#{version} (#{cycle})"
    end
    alias :info :to_s

    # Returns module formatted name for versioning.
    def to_version_s
      "#{self.name.downcase}-#{version}"
    end

  end

end # module Postage


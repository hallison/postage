# Copyright (C) 2009, Hallison Batista
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

# Main module for API.
module Postage

  # RubyGems
  require 'rubygems'

  # 3rd part gems
  require 'maruku'

  # Core
  require 'pathname'
  require 'ostruct'
  require 'erb'

  # Internal requires
  require 'postage/extensions'

  # Root directory for references library.
  ROOT = Pathname.new("#{File.dirname(__FILE__)}/..")

  # Auto-load information libraries
  autoload :About,         'postage/about'
  autoload :Version,       'postage/version'

  # Auto-load main libraries
  autoload :Post,          'postage/post'
  autoload :Finder,        'postage/finder'

end # module Postage


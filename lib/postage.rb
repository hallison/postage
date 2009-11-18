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
  ROOT = Pathname.new("#{File.dirname(__FILE__)}/..").expand_path

  # Auto-load main libraries
  autoload :Entry,  'postage/entry'
  autoload :Post,   'postage/post'
  autoload :Finder, 'postage/finder'

  # Version
  def self.version
    @version ||= Version.current
  end

  class Version #:nodoc:

    FILE = Postage::ROOT.join("VERSION")

    attr_accessor :tag, :date, :cycle
    attr_reader :timestamp

    def initialize(options = {})
      options.symbolize_keys.instance_variables_set_to(self)
    end

    def to_hash
      [:tag, :date, :cycle, :timestamp].inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    def save!
      self.date = Date.today
      FILE.open("w+") { |file| file << self.to_hash.to_yaml }
      self
    end

    def self.current
      new(YAML.load_file(FILE))
    end

  end

end # module Postage


# Copyright (C) 2009, Hallison Batista
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

# Postage is a generic interface (API) which load your text files and handle the
# contents in Markdown or Textile syntax.
# 
# It's useful for _blog engines_, static page generator, or anything else, that
# uses flat files organized in directories instead databases.
# 
# It's possible uses Markdown Extra syntax because Postage use Maruku as default
# library for converting files that uses this format.
module Postage

  # RubyGems
  require 'rubygems'

  # 3rd part gems
  require 'maruku'

  # Core
  require 'pathname'
  #require 'ostruct'
  require 'yaml'
  require 'erb'

  # Internal requires
  require 'postage/extensions'

  # Root directory for references library.
  ROOT = Pathname.new("#{File.dirname(__FILE__)}/..").expand_path

  # Auto-load main libraries
  autoload :Entry,  'postage/entry'
  autoload :Post,   'postage/post'
  autoload :Finder, 'postage/finder'

  class << self

    # Configuration options for post class.
    def configure(attributes = {}, &block)
      @config = Config.new(attributes)
      block_given? ? (yield config) : config
    end

    # Entry config
    def config
      @config ||= Config.new do |default|
        default.path = "."
        default.format = ":metaname.:extname"
      end
    end

    # Version
    def version
      @version ||= Version.current
    end

  end

  class Base
    def initialize(attributes = {})
      attributes.each do |attribute, value|
        instance_variable_set("@#{attribute}", value) if respond_to? attribute
      end
    end
  end

  # Postage configuration class
  #
  # == Meta-attributes
  #
  # You can assign meta-attributes in format file name. The meta-attributes are:
  # 
  # [<b>:metaname</b>]
  #   File name which point to entry title.
  # [<b>:extname</b>]
  #   File extension which describe a filter.
  # [<b>:year</b>,<b>:month</b>,<b>:day</b>]
  #   Entry publish date attributes.
  # [<b>:tags</b>]
  #   Tags.
  #
  # Examples:
  #   # For simple entry file
  #   Postage.configure do |config|
  #     config.path   = "~/hallison/docs"
  #     config.format = ":metaname.:extname"
  #   end
  #
  #   # For articles (posts):
  #   Postage.configure do |config|
  #     config.path   = "~/hallison/posts"
  #     config.format = ":year-:month-:day-:metaname.:tags.:extname"
  #   end
  #
  class Config < Base

    # Path of the placed all entry files.
    attr_reader :path

    # Format for file names.
    # Assign a mask for entry format and creates a #glob.
    attr_accessor :format

    # File name patterns.
    attr_reader :patterns

    # Criates a new configuration for entry files.
    def initialize(attributes = {})
      super(attributes)
      yield self if block_given?
      extract_patterns_format
      build_glob
    end

    # Assign path and creates #glob if #format exists.
    def path=(dir)
      @path = Pathname.new(dir).expand_path
    end

    # Glob file list for entry file patterns.
    def glob_files
      Dir[@glob]
    end

  private

    # Extract and filter all attribute names pattern of the format mask.
    def extract_patterns_format
      @patterns = @format.split(/:(.*?)/).reject do |key|
                    key.empty?
                  end.map do |key|
                    key.split(/(\W)/)
                  end
    end

    # Build a Glob pattern for listing entry files.
    def build_glob
      @glob = @path.join(@patterns.map{ |(key, delimiter)| ["*", delimiter] }.join).to_s
    end

  end # class Config

  class Version < Base #:nodoc:

    FILE = Postage::ROOT.join(".version")

    attr_accessor :tag, :date, :milestone
    attr_reader :timestamp

    def to_hash
      [:tag, :date, :milestone, :timestamp].inject({}) do |hash, key|
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

  end # class Version

end # module Postage


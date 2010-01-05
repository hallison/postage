# Copyright (c) 2009 Hallison Batista
#
# Class for handle a text entry using a file that written with any supported filter
# (Markdown or Textile) syntax.
#
# Example:
#  # file: anything-written-using-markdown.mkd
#  #
#  # Anything written using Markdown
#  # ===============================
#  #
#  # The content of this _file_ will be render to [HTML][] using [Postage::Entry][postage
#  # entry] class.
#  #
#  # [html]: http://en.wikipedia.org/wiki/HTML/
#  # [postage entry]: http://github.com/hallison/postage/
#  #
#  page = Postage::Entry.new("anything-written-using-markdown.mkd").extract_attributes!
class Postage::Entry < Postage::Base

  require 'forwardable'

  extend Forwardable

  def_delegators :file, :dirname, :basename, :extname, :file?, :exist?

  # Entry file.
  attr_reader :file

  # Entry file name without filter (extension).
  attr_reader :name

  # Filter that will used for parse entry content.
  attr_reader :filter

  # Title of the entry. This attribute accepts Markdown syntax.
  attr_reader :title

  # Entry content.
  attr_reader :content

  # Initialize a entry using attributes by name.
  # Example:
  #  # entry = Postage::Entry.new :title   => "# New title for a new entry",
  #  #                            :filter  => :markdown,
  #  #                            :name    => "new-entry",
  #  #                            :content => <<-end_content
  #  # Wow! Use Postage in your projects. Is very easy.
  #  #
  #  # It works and is a better solution for page generators or handle text
  #  # files.
  #  # end_content
  #
  # The Entry file will be generated based in file name and filter for extension.
  def initialize(attributes = {})
    super(attributes)
    if @file
      extract_name
      extract_filter
    end
  end

  # Initialize a entry using file name.
  def self.file(file_name)
    new :file => Pathname.new(file_name).expand_path
  end

  def self.load(file_name)
    file(file_name).extract_attributes!
  end

  # Find all post files placed in path using pattern file name.
  # See #configure method for more information about this.
  def self.files(&block)
    @files = Postage.config.glob_files.map do |file_name|
      file(file_name)
    end
    block_given? ? @files.map(&block) : @files
  end

  # Load all attributes from file.
  def extract_attributes!
    extract_filter
    extract_title_and_content
    extract_title if @title.empty?
    self
  end

  # Create file and write title and content.
  def create!
    create_file_name unless @file
    create_file_extension if extname.empty?
    create_title unless @title
    create_path
    create_file
    self
  end

  # Returns file path.
  def to_s
    file.to_s
  end

  #
  def title_to_html
    Maruku.new("#{title}").to_html.gsub(/<h1.*?>(.*)<\/h1>/){$1}
  end

  #
  def content_to_html
    Maruku.new("#{content.join}").to_html
  end

  # Parse all content (title + content) to HTML. If you want parse attributes
  # to HTML individually, use #title_to_html and/or #content_to_html.
  def to_html
    Maruku.new("#{title}\n#{content.join}").to_html
  end

  # Returns file extension by filter.
  # Default is <tt>.mkd</tt> (Markdown).
  def extension
    case @filter
    when :markdown then "mkd"
    when :textile  then "txl"
    when :text     then "txt"
    when :unknow   then "mkd"
    else extname.delete(".")
    end
  end

private

  # Extract title and content from file.
  def extract_title_and_content
    @content ||= @file.readlines
    @title   ||= @content.shift
    @title    << @content.shift if (@content.first =~ /^[=]{3,}/)
    [@title, @content]
  end

  # Extract name from file name.
  def extract_name
    @name = basename.to_s.split(".").first
  end

  # Extract filter from file name. Default filer is <tt>:markdown</tt>
  def extract_filter
    @filter = case extname
              when /md$|mkd$|mkdn$|mark.*?$/
                :markdown
              when /tx$|txl$|text.*?$/
                :textile
              when /txt$/
                :text
              else
                :unknow
              end
  end

  # Creates path for entry file.
  def create_path
    @file.mkpath unless @file.dirname.exist?
  end

  # Creates file with name extracted from title. This method depends on the
  # file name.
  def create_file
    @file.open "w+" do |line|
      line << @title
      line << @content
    end
  end

  # Creates a new title from file name.
  def create_title
    _title = @file.basename.to_s.gsub(/[-_]|\.(.*)$/, ' ').capitalize.strip
    @title = "#{_title}\n#{'='*_title.size}\n"
  end

  # Create file name from title.
  def create_file_name
    @file = "#{name || create_name}.#{extension}"
  end

  # Create file using extension by filter.
  def create_file_extension
    @filter = :markdown
    @file   = Pathname.new("#{@file}.mkd")
  end

  def create_name
    @title.to_s.gsub(/[=\n\W]/,' ').squeeze(' ').strip.gsub(/[\s\W]/,"_").downcase
  end

end # class Postage::Entry


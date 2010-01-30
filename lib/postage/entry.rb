# = Postage Entry class
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
#  page = Postage::Entry.file("anything-written-using-markdown.mkd").extract_attributes!
class Postage::Entry < Postage::Base

  require 'forwardable'

  extend Forwardable

  def_delegators :file, :file?, :exist?

  # Entry file.
  attr_reader :file

  # Entry file name without filter (extension).
  attr_reader :name

  # Filter that will used for parse entry content.
  attr_accessor :filter

  # Title of the entry. This attribute accepts Markdown syntax.
  attr_accessor :title

  # Entry content.
  attr_accessor :content

  # Initialize a entry using attributes by name.
  # Example:
  #  # entry = Postage::Entry.new :title   => "# New title for a new entry",
  #  #                            :filter  => :markdown,
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
    extract_attributes if file
  end

  # Create file path.
  def file=(file)
    @file = Pathname.new(file).expand_path
  end

  # Initialize a entry using file name.
  def self.file(file) #:yields:entry
    entry = new(:file => file)
    block_given? && (yield entry) || entry
  end

  # Initialize a entry using file name and load all attributes and contents.
  def self.load(filename)
    file(filename).extract_attributes.extract_contents
  end

  # Find all post files placed in path using pattern file name.
  # See #configure method for more information about this.
  def self.files(&block) #:yields:entry
    @files = Postage.config.glob_files.map do |file_name|
      file(file_name)
    end
    block_given? ? @files.map(&block) : @files
  end

  # Load title and content body.
  def extract_contents
    extract_title_and_content
    self
  end

  # Load all attributes from file.
  def extract_attributes
    extract_name
    extract_filter
    self
  end

  # Create file and write title and content.
  def create!
    create_file_name unless @file
    create_file_extension if @file.extname.empty?
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

  # Returns file extension by filter. Default is <tt>.mkd</tt> (Markdown).
  def extension
    extract_filter unless @filter
    case @filter
    when :markdown then "mkd"
    when :textile  then "txl"
    when :text     then "txt"
    when :unknow   then "mkd"
    else @file.extname.delete(".")
    end
  end

private

  # Extract name from file name.
  def extract_name
    @name = @file.basename.to_s.split(".").first
  end

  # Extract filter from file name. Default filer is <tt>:markdown</tt>
  def extract_filter
    @filter = case @file.extname
              when /md$|mkd$|mkdn$|mark.*?$/
                :markdown
              when /tx$|txl$|text.*?$/
                :textile
              when /txt$/
                :text
              else
                :unknow
              end if @file
  end

  # Extract title and content from file.
  def extract_title_and_content
    @content ||= @file.readlines
    @title   ||= @content.shift
    @title    << @content.shift if (@content.first =~ /^[=]{3,}/)
    [@title, @content]
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
    create_name unless @name
    @file = Pathname.new(Postage.config.path.join("#{name}.#{extension}"))
  end

  # Create file using extension by filter.
  def create_file_extension
    @filter = :markdown
    @file   = Pathname.new("#{@file}.mkd")
  end

  def create_name
    @name = @title.to_s.gsub(/[=\n\W]/,' ').squeeze(' ').strip.gsub(/[\s\W]/,"_").downcase
  end

end # class Postage::Entry


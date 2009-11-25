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
class Postage::Entry

  Options = Struct.new :path, :pattern

  # Entry file name.
  attr_reader :file

  # Filter that will used for parse entry content.
  attr_reader :filter

  # Title of the entry. This attribute accepts Markdown syntax.
  attr_reader :title

  # Entry content.
  attr_reader :content

  # Initialize a entry using attributes by name.
  def initialize(attributes = {})
    attributes.instance_variables_set_to(self)
  end

  # Initialize a entry using file name.
  def self.file(file_name)
    new :file => Pathname.new(file_name).expand_path
  end

  def self.load(file_name)
    file(file_name).extract_attributes!
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
    Maruku.new("#{content}").to_html
  end

  # Parse all content (title + content) to HTML. If you want parse attributes
  # to HTML individually, use #title_to_html and/or #content_to_html.
  def to_html
    Maruku.new("#{title}\n#{content}").to_html
  end

  # Configuration custom options.
  # Example:
  #  Postage::Entry.configure do |options|
  #    options.path = "~/documents/pages" # path location for all entries
  #    options.pattern = "*.mkd"          # pattern for file names
  #  end
  #  Postage::Entry.find_all # find all entry files placed in path.
  def self.configure
    yield options
  end

  # Entry options
  def self.options
    @@options ||= Options.new ".", "*.{mkd,txl,txt}"
  end

  # Find all entry files placed in path using pattern file name.
  # See #configure method for more information about this.
  def self.files(&block)
    @@files = Dir["#{options.path}/#{options.pattern}"].map do |file_name|
      file(file_name)
    end
    block_given? ? @@files.map(&block) : @@files
  end

private

  # Extract title and content from file.
  def extract_title_and_content
    @content ||= @file.readlines
    @title   ||= @content.shift
    @title    << @content.shift if (@content.first =~ /^[=]{3,}/)
    [@title, @content]
  end

  # Extract filter from file name.
  def extract_filter
    @file.basename.to_s.scan(%r{.*\.(.*)$}) do |filter|
      @filter ||= case filter.to_s
                  when /md$|mkd$|mark.*?$/
                    :markdown
                  when /tx$|txl$|text.*?$/
                    :textile
                  when /txt$/
                    :text
                  else
                    :unknow
                  end
    end
    @filter
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
    _filename = @title.to_s.
      gsub(/[=\n\W]/,' ').
      squeeze(' ').strip.
      gsub(/[\s\W]/,"_").downcase
    @file = self.class.options.path.join("#{_filename}.#{file_extension}")
  end

  def create_file_extension
    @filter ||= :markdown
    @file = Pathname.new("#{@file}.#{file_extension}")
  end

  # Returns file extension by filter.
  # Default is <tt>.mkd</tt> (Markdown).
  def file_extension
    case @filter
    when :markdown then "mkd"
    when :textile  then "txl"
    when :text     then "txt"
    when :unknow   then "mkd"
    else "mkd"
    end
  end

end


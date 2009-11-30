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

  # Entry supports configurations for customize file formats and paths.
  #
  # Example:
  #
  #   Postage::Entry.configure do |options|
  #     options.path = "~/documents"          # path location for all entries
  #     options.format = ":metaname.:extname" # file format name
  #   end
  class Configuration

    # Path of the placed all entry files.
    attr_reader :path

    # Entry file format.
    attr_reader :format

    # File name patterns.
    attr_reader :patterns

    # Glob file names.
    attr_reader :glob

    # Criates a new configuration for entry files.
    def initialize(&block)
      super
      block_given? ? (yield self) : self
    end

    # Assign path and creates #glob if #format exists.
    def path=(dir)
      @path = Pathname.new(dir).expand_path
      glob! if @format
      @path
    end

    # Assign a mask for entry format and creates a #glob.
    def format=(mask)
      @format = mask
      glob!
      @format
    end

    # Assign a Glob list for entry file patterns.
    def glob!
      extract_patterns_format
      build_glob
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

  end

  # Configuration options for post class.
  def self.configure(&block)
    block_given? ? (yield options) : options
  end

  # Entry options
  def self.options
    @@options ||= Configuration.new do |default|
      default.path = "."
      default.format = ":metaname.:extname"
    end
  end

  # Entry file.
  attr_reader :file

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
  #  #                            :file    => "new-entry",
  #  #                            :content => <<-end_content
  #  # Wow! Use Postage in your projects. Is very easy.
  #  #
  #  # It works and is a better solution for page generators or handle text
  #  # files.
  #  # end_content
  #
  # The Entry file will be generated based in file name and filter for extension.
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

  # Find all post files placed in path using pattern file name.
  # See #configure method for more information about this.
  def self.files(&block)
    @files = Dir["#{options.glob}"].map do |file_name|
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
    @filter = case @file.extname
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
    @file = "#{file_name}.#{file_extension}"
  end

  # Create file using extension by filter.
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

  def file_name
    @title.to_s.gsub(/[=\n\W]/,' ').squeeze(' ').strip.gsub(/[\s\W]/,"_").downcase
  end

end # class Postage::Entry


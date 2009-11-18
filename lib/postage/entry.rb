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

  # Entry file name
  attr_reader :file

  # Filter that will used for parse entry content
  attr_reader :filter

  # Title of the entry. This attribute accepts Markdown syntax.
  attr_reader :title

  # Content
  attr_reader :content

  # Initialize a entry using attributes by name.
  def initialize(filename)
    @file = Pathname.new(filename).expand_path
  end

  def self.load(filename)
    new(filename).extract_attributes!
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
    create_path
    create_file
    self
  end

  # Returns file path.
  def to_s
    file.to_s
  end

  def title_to_html
    Maruku.new("#{title}").to_html.gsub(/<h1.*?>(.*)<\/h1>/){$1}
  end

  def content_to_html
    Maruku.new("#{content}").to_html
  end

  def to_html
    Maruku.new("#{title}\n#{content}").to_html
  end

  # Configuration custom options.
  def self.configure
    yield options
  end

  # Entry options
  def self.options
    @@options ||= Options.new ".", "*.{mkd,txl,txt}"
  end

  # Find all entries from path using pattern file name.
  def self.find_all(&block)
    @@list = Dir["#{options.path}/#{options.pattern}"].map do |filename|
      new(filename)
    end
    (block_given?) ? (yield @@list.map) : @@list
  end

protected

  # Extract title and content from file.
  def extract_title_and_content
    @content ||= @file.readlines
    @title   ||= [@content.shift]
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

  #def extract_tags(filename)
  #  filename.scan(%r{^.*?\.(.*)\..*}).to_s.split(".")
  #end

  def create_path
    @file.mkpath unless @file.dirname.exist?
  end

  def create_file
    create_title
    @file.open "w+" do |line|
      line << @title
      line << @content
    end
  end

  # Creates a new title from file name.
  def create_title
    _title = @file.basename.to_s.gsub(/[-_]|\.(.*)$/, ' ').capitalize.strip
    @title = [ "#{_title}\n", "="*_title.size+"\n" ]
  end

end


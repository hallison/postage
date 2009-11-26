# Copyright (c) 2009, Hallison Batista
#
# Main class for handle text files. The Post class load file and extract all
# attributes from name. Examples:
#
# If you want load a file, use:
#
#   post = Postage::Post.load("posts/20090710-my_post_file.ruby.postage.mkd")
#   # => post.title        : My post file
#   # => post.publish_date : 2009-07-10
#   # => post.tags         : ruby, postage
#   # => post.filter       : markdown
#
# Or, if you want initialize a new post, use:
#
#   post = Postage::Post.new :title        => "Creating new `entry` from test unit",
#                            :publish_date => Date.new(2009,7,10),
#                            :tags         => %w(ruby postage),
#                            :filter       => :markdown,
#                            :content      => <<-end_content.gsub(/[ ]{2}/,'')
#     Ok. This is a test for create new `entry` from test unit and this paragraph will be
#     the post summary.
#
#     In this file, I'll write any content ... only for test.
#     Postage is a lightweight API for load posts from flat file that contains
#     text filtered by [Markdown][] syntax.
#
#     [markdown]: http://daringfireball.net/projects/markdown/
#   end_content
class Postage::Post < Postage::Entry

  # Post publish date, of course.
  attr_reader :date

  # Tags accepts only one word per tag.
  attr_reader :tags

  # Summary is a first paragraph of content.
  attr_reader :summary

  # Check and extract all attributes from file name.
  def extract_attributes!
    super
    @summary = @content.match(%r{<p>.*</p>}).to_s
    self
  end

  # Return post name formatted ("year/month/day/name").
  def to_s
    @file.to_s.scan(%r{(\d{4})(\d{2})(\d{2})(.*?)-(.*?)\..*}) do |year,month,day,time,name|
      return "#{year}/#{month}/#{day}/#{name}"
    end
  end

  # Build post file name and return following format: yyyymmdd-post_name.tags.separated.by.points.filter
  def build_file
    @file = "#{build_publish_date}-#{build_file_name}.#{build_tags}.#{build_filter}"
  end

  # Get post file name and creates content and save into directory.
  def create_into(directory)
    build_file
    Pathname.new(directory).join(@file).open 'w+' do |file|
      post = self
      file << ERB.new(load_template).result(binding)
    end
  end

  # Test pattern in title or filename.
  def matched?(regexp)
    @title.match(regexp) || @file.match(regexp)
  end

  # Sort posts by file name.
  def <=>(post)
    @file.basename.to_s <=> post.file.basename.to_s
  end

private

  REGEXP_DATE     = %r{/(\d{4})[-_]{0,1}(\d{2})[-_]{0,1}(\d{2})[-_]{0,1}.*}
  REGEXP_DATETIME = %r{/(\d{4})[-_]{0,1}(\d{2})[-_]{0,1}(\d{2})[-_]{0,1}(\d{2})[-_]{0,1}(\d{2})[-_]{0,1}(\d{2})[-_]{0,1}.*}

  def extract_summary
    @summary = @content.to_s.match(%r{\n.*?\n\n}m).to_s
  end

  def extract_tags
    @tags = @file.to_s.scan(%r{^.*?\.(.*)\..*}).to_s.split(".")
  end

  def extract_date
    regexp = @file.to_s =~ REGEXP_DATETIME ? REGEXP_DATETIME : REGEXP_DATE
    @file.to_s.scan(regexp) do |year, month, day, hour, min, sec|
      @date = if hour && min && sec
                DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i, sec.to_i)
              else
                Date.new(year.to_i, month.to_i, day.to_i)
              end
    end
    @date
  end

  def load_template
    File.read(template)
  end

  def template
    ROOT.join('templates','post.erb')
  end

end # class Postage::Post


$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'lib/postage'
require 'test/unit'
require 'test/customizations'

class EntryTest < Test::Unit::TestCase

  PATH = Pathname.new(File.dirname __FILE__)

  Postage::Entry.class_eval do
    public :extract_filter
  end

  def setup
    @attributes = {
      :file => PATH.join("fixtures/entry_test.mkd").expand_path,
      :title => ["Entry *test*\n", "============\n"],
      :content => ["\n", "Entry *test*. This content uses [Markdown][] syntax.\n", "\n",
                   "[markdown]: http://daringfireball.net/projects/markdown/\n", "\n"],
      :filter => :markdown
    }
    @options = {
      :path => PATH.join("fixtures"),
      :pattern => "*entry*.mkd"
    }
    Postage::Entry.configure do |entry|
      @options.map do |option, value|
        entry.send("#{option}=", value)
      end
    end
    @entry = Postage::Entry.new(@attributes[:file])
  end

  should "extract filter from file name" do
    assert_equal :markdown, Postage::Entry.new("test.mkd").send(:extract_filter)
    assert_equal :text, Postage::Entry.new("test.mkd.txt").send(:extract_filter)
    assert_equal :unknow, Postage::Entry.new("test-k1.txtd").send(:extract_filter)
  end

  should "extract title and content from file" do
    title, content = @entry.send(:extract_title_and_content)
    assert_equal title, @attributes[:title]
    assert_equal content, @attributes[:content]
  end

  should "validates entry attributes" do
    @entry.extract_attributes!
    @attributes.each do |attribute, value|
      assert_equal value, @entry.send(attribute)
    end
  end

  should "create a new entry file" do
    entry = Postage::Entry.new("#{PATH}/fixtures/new_entry_test.mkd").create!
    assert entry.file.exist?
    assert entry.file.file?
    assert_equal ["New entry test\n", "==============\n"], entry.title
  end

  should "parse to html" do
    @entry.extract_attributes!
    assert_match /^<h1.*?>.*?<\/h1>.*<p.*>.*?<\/p>/m, @entry.to_html
    assert_match /^.*?|.*?<.*?>/, @entry.title_to_html
    assert_match /<.*?>.*?<\/.*>/, @entry.content_to_html
  end

  should "check attributes configuration" do
    @options.map do |option, value|
      assert_equal value, Postage::Entry.options.send(option)
    end
  end

  should "find all entries" do
    entries = Postage::Entry.find_all
    assert_equal 2, entries.size
  end

end


$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'lib/postage'
require 'test/unit'
require 'test/customizations'

class EntryTest < Test::Unit::TestCase

  PATH = Pathname.new(File.dirname(__FILE__)).join("fixtures/entries").expand_path

  def setup
    @attributes = {
      :title   => "Entry *test*\n============\n",
      :content => ["\n", "Entry *test*. This content uses [Markdown][] syntax.\n", "\n",
                   "[markdown]: http://daringfireball.net/projects/markdown/\n", "\n"],
      :filter  => :markdown
    }

    @file    = PATH.join("entry_test.mkd")
    @options = {
      :path   => PATH,
      :format => ":name.:extension"
    }

    Postage.configure @options

    @entry = Postage::Entry.file(@file)
  end

  should "extract filter from file" do
    assert_equal :markdown, Postage::Entry.file("test.mkd").send(:extract_filter)
    assert_equal :text,     Postage::Entry.file("test.mkd.txt").send(:extract_filter)
    assert_equal :unknow,   Postage::Entry.file("test-k1.txtd").send(:extract_filter)
  end

  should "extract name from file" do
    assert_equal "test",    Postage::Entry.file("test.mkd").send(:extract_name)
    assert_equal "test",    Postage::Entry.file("test.mkd.txt").send(:extract_name)
    assert_equal "test-k1", Postage::Entry.file("test-k1.txtd").send(:extract_name)
  end

  should "extract title and content from file" do
    title, content = @entry.send(:extract_title_and_content)

    assert_equal @attributes[:title],   title
    assert_equal @attributes[:content], content
  end

# should "generate file using only attributes" do
#   entry = Postage::Entry.new(@attributes)

#   assert_equal "entry_test", entry.name
#   assert_equal "mkd",        entry.extension
#   assert_equal @file,        entry.file
# end

# should "validates entry attributes" do
#   @entry.extract_attributes!
#   @attributes.each do |attribute, value|
#     assert_equal value, @entry.send(attribute)
#   end
# end

# should "create a new entry file" do
#   entry = Postage::Entry.file("#{PATH}/new_entry_test.mkd").create!
#   assert entry.exist?
#   assert entry.file?
#   assert_equal "New entry test\n==============\n", entry.title

# end

# should "create a new entry from attributes" do
#   entry = Postage::Entry.new :title   => "New entry test\n==============\n",
#                              :name    => "new_entry_test_again",
#                              :content => <<-end_content.gsub(/^[ ]{6}/, '')

#     New _content_ for **new entry**.

#   end_content
#   entry.create!
#   assert entry.exist?
#   assert entry.file?
#   assert_equal PATH.expand_path, entry.file.dirname
#   assert_equal :markdown, entry.filter
#   assert_equal "New entry test\n==============\n", entry.title
# end

# should "parse to html" do
#   @entry.extract_attributes!
#   assert_match /^<h1.*?>.*?<\/h1>.*<p.*>.*?<\/p>/m, @entry.to_html
#   assert_match /^.*?|.*?<.*?>/, @entry.title_to_html
#   assert_match /<.*?>.*?<\/.*>/, @entry.content_to_html
# end

# should "find all entries" do
#   entries = Postage::Entry.files do |entry|
#     assert_equal @options[:path], entry.file.dirname
#   end

#   assert_equal 3, entries.size
# end

end


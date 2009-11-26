$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'lib/postage'
require 'test/unit'
require 'test/customizations'

class PostTest < Test::Unit::TestCase

  PATH = Pathname.new(File.dirname __FILE__).expand_path

  def setup
    @attributes = {
      :file => PATH.join("fixtures/20090604-postage_test_post.ruby.postage.mkd"),
      :date => Date.new(2009, 06, 04),
      :title => "Postage test *post*\n===================\n",
      :content => ["\n",
                   "\n",
                   "The firs paragraph is a summary of the post.\n",
                   "\n",
                   "The title os post is a first line of document.\n",
                   "All attributes are specified in file name.\n",
                   "\n",
                   "    yyyymmdd-name_of_file.tags.filter\n",
                   "\n",
                   "Simple and easy.\n",
                   "\n" ],
      :tags => ["ruby", "postage"],
      :filter => :markdown
    }
    @post = Postage::Post.file(@attributes[:file])
  end

  should "extract summary from content" do
    post = Postage::Post.new :content => <<-end_content.gsub(/^[ ]{6}/, "")

      This is a paragraph that be used how summary.

      Here is placed content.
    end_content
    assert_match /This.*summary.*\.\n/m, post.send(:extract_summary).to_s
  end

  should "extract tags" do
    assert_equal %w[k2 k3], Postage::Post.file("test-k1.k2.k3.mkd").send(:extract_tags)
    assert_equal %w[k2-k3], Postage::Post.file("test-k1.k2-k3.mkd").send(:extract_tags)
    assert_equal %w[k3], Postage::Post.file("test-k1-k2.k3.mkd").send(:extract_tags)
  end

  should "extract date or datetime" do
    assert_equal Date.new(2005,6,2), Postage::Post.file("2005-06-02-test-file.tag.mkd").send(:extract_date)
    assert_equal Date.new(2005,6,2), Postage::Post.file("2005_06_02-test_file.tag.mkd").send(:extract_date)
    assert_equal Date.new(2005,6,2), Postage::Post.file("20050602-test_file.tag.mkd").send(:extract_date)
    assert_equal DateTime.new(2005,6,2,12,38,5), Postage::Post.file("2005-06-02-12-38-05-test-file.tag.mkd").send(:extract_date)
    assert_equal DateTime.new(2005,6,2,12,38,5), Postage::Post.file("2005_06_02_12_38_05-test_file.tag.mkd").send(:extract_date)
    assert_equal DateTime.new(2005,6,2,12,38,5), Postage::Post.file("20050602123805-test_file.tag.mkd").send(:extract_date)
  end

# should "validates post attributes" do
#   @post.extract_attributes!
#   @attributes.each do |attribute, value|
#     assert_equal value, @post.send(attribute)
#   end
#   assert_equal "2009/06/04/postage_test_post", "#{@post}"
# end

# should "check html in content" do
#   assert_match %r{<p>.*?</p>}, @post.content
# end

# should "create new post file" do
#   @post = Postage::Post.new :title   => "Creating new `post` from test unit",
#                             :date    => Date.new(2009,6,8),
#                             :tags    => %w(ruby postage test),
#                             :filter  => :markdown,
#                             :content => <<-end_content.gsub(/^[ ]{6}/,'')
#     Ok. This is a test for create new `entry` from test unit and this paragraph will summary.

#     In this file, I'll write any content ... only for test.
#     Postage is a lightweight API for load posts from flat file that contains
#     text filtered by [Markdown][] syntax.

#     [Markdown]: http://daringfireball.net/projects/markdown/
#   end_content

#   assert_equal "20090608-creating_new_post_from_test_unit.ruby.postage.test.mkd", @post.build_file
#   @post.create_into "#{File.dirname(__FILE__)}/fixtures"
#   assert File.exist?("#{File.dirname(__FILE__)}/fixtures/#{@post.file}")
# end

end


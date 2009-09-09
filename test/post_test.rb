$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'test/unit'
require 'lib/postage'

class TestPost < Test::Unit::TestCase

  def setup
    @attributes = {
      :publish_date => Date.new(2009, 06, 04),
      :title => "Postage test <em>post</em>",
      :tags => %w(ruby postage),
      :filter => :markdown,
      :file   => "#{File.dirname(__FILE__)}/fixtures/20090604-postage_test_post.ruby.postage.mkd"
    }
    @post = Postage::Post.load("#{File.dirname(__FILE__)}/fixtures/20090604-postage_test_post.ruby.postage.mkd")
  end

  def test_should_load_attributes_from_file_name_with_simple_date
    @attributes.each do |attribute, value|
      assert_equal value, @post.send(attribute)
    end
    assert_equal "2009/06/04/postage_test_post", "#{@post}"
  end

  def test_should_load_attributes_from_file_name_with_datetime
    @attributes.update(
      :publish_date => DateTime.new(2009,6,4,14,38,5),
      :file         => "#{File.dirname(__FILE__)}/fixtures/20090604143805-postage_test_post.ruby.postage.mkd"
    )
    @post = Postage::Post.load("#{File.dirname(__FILE__)}/fixtures/20090604143805-postage_test_post.ruby.postage.mkd")
    @attributes.each do |attribute, value|
      assert_equal value, @post.send(attribute)
    end
    assert_equal "2009/06/04/postage_test_post", "#{@post}"
  end

  def test_should_check_html_in_content
    assert_match %r{<p>.*?</p>}, @post.content
  end

  def test_should_create_new_post_file
    @post = Postage::Post.new :title        => "Creating new `entry` from test unit",
                              :publish_date => Date.new(2009,6,8),
                              :tags         => %w(ruby postage test),
                              :filter       => :markdown,
                              :content      => <<-end_content.gsub(/[ ]{6}/,'')
      Ok. This is a test for create new `entry` from test unit and this paragraph will summary.

      In this file, I'll write any content ... only for test.
      Postage is a lightweight API for load posts from flat file that contains
      text filtered by [Markdown][] syntax.

      [Markdown]: http://daringfireball.net/projects/markdown/
    end_content

    assert_equal "20090608-creating_new_entry_from_test_unit.ruby.postage.test.mkd", @post.build_file
    @post.create_into "#{File.dirname(__FILE__)}/fixtures"
    assert File.exist?("#{File.dirname(__FILE__)}/fixtures/#{@post.file}")
  end
end


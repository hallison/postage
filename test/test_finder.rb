$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'test/unit'
require 'lib/postage'

class TestFinder < Test::Unit::TestCase

  def setup
    @find = Postage::Finder.new("#{File.dirname(__FILE__)}/fixtures")
  end

  def test_should_find_post
    date = Date.new(2009,6,4)
    assert_equal date, @find.post(*date.to_args << 'postage').publish_date
    assert_equal date, @find.post(*%w[2009 06 04 postage]).publish_date
  end

  def test_should_load_all_posts
    assert_equal 5, @find.all_posts.size
  end

  def test_should_load_all_tags
    assert_equal 3, @find.all_post_tags.size
  end

end


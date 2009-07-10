$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'test/unit'
require 'lib/postage'

class TestFinder < Test::Unit::TestCase

  def setup
    @find = Postage::Finder.new("#{File.dirname(__FILE__)}/fixtures")
  end

  def test_should_find_post
    date = Date.new(2009,6,4)
    post = @find.post(date, 'postage')
    assert_not_nil post
    assert date, post.publish_date
  end

  def test_should_load_all_posts
    posts = @find.all_posts
    assert 4, posts.size
  end

  def test_should_load_all_tags
    tags = @find.all_post_tags
    assert 3, tags.size
  end

end


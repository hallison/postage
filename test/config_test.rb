$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'lib/postage'
require 'test/unit'
require 'test/customizations'

class ConfigTest < Test::Unit::TestCase

  PATH = Pathname.new(File.dirname(__FILE__)).expand_path

  def setup
    @options = {
      :path => PATH.join("fixtures"),
      :format => ":year-:month-:day-:name.:tags.:extension"
    }
    @config = Postage.configure @options
  end

  should "parse file format to regexp patterns" do
    patterns = [
      ["year", "-"],
      ["month","-"],
      ["day", "-"],
      ["name","."],
      ["tags", "."],
      ["extension"]
    ]
    assert_equal @options[:path],   @config.path
    assert_equal @options[:format], @config.format
    assert_equal patterns, @config.patterns
  end

end


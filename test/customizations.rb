# This code extracted from book "Ruby Best Practices" and the code be found
# in http://github.com/sandal/rbp/blob/master/testing/test_unit_extensions.rb
module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock
  AssertionFailedError = Class.new(StandardError)
  
  class TestCase
   
    def self.should(description, &block)
      test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{description}"
        end
      end
    end
 
  end

end


class Hash

  # Only symbolize all keys, including all key in sub-hashes. 
  def symbolize_keys
    self.inject({}) do |hash, (key, value)|
      hash[key.to_sym] = if value.kind_of? Hash
                           value.symbolize_keys
                         else
                           value
                         end
      hash
    end
  end

  # Set instance variables by key and value only if object respond
  # to access method for variable.
  def instance_variables_set_to(object)
    collect do |variable, value|
      object.instance_variable_set("@#{variable}", value) if object.respond_to? variable
    end
    object
  end

end

class Date

  # Stringify date and split by '-'.
  #
  #     date = Date.new(2009,6,9)
  #     date.to_s     # => 2009-06-09
  #     date.to_args  # => [ "2009", "06", "09" ]
  def to_args
    self.to_s.split('-')
  end

end

class Array

  # Returns elements between first and the specific limit.
  def limit(size)
    self[0..size]
  end

end


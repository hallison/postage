# Copyright (C) 2009, Hallison Batista
module Postage

module About #:nodoc:

  class << self

    def info
      @about ||= OpenStruct.new(YAML.load_file(ROOT.join("INFO")))
    end

    def to_s
      <<-end_info.gsub(/      /,'')
      #{Version}
      Copyright (C) #{Version.info.timestamp.year} #{info.authors.join(', ')}

      #{info.description}
 
      For more information, please see the project homepage
      #{info.homepage}. Bugs, enhancements and improvements,
      please send message to #{info.email}.
      end_info
    end

  end

end # module About

end # module Postage


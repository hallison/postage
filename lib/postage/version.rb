# Copyright (C) 2009, Hallison Batista
module Postage

module Version #:nodoc:

  class << self

    def info
      @version ||= OpenStruct.new(YAML.load_file(ROOT.join("VERSION")))
    end

    def tag
      %w{major minor patch release}.map do |tag|
        info.send(tag)
      end.compact.join(".")
    end

    def to_s
      "#{name.sub(/::.*/,'')} v#{tag} (#{info.date.strftime('%B, %d %Y')}, #{info.cycle})"
    end

  end

end # module Version

end # module Postage


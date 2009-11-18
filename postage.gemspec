Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY

  # About
  spec.name = "postage"
  spec.summary = "Postage API implemented for helper handle text files for posts."
  spec.description = "Postage is an API developed for handle text files for posts for blogs or anything else."
  spec.authors = ["Hallison Batista"]
  spec.email = "email@hallisonbatista.com"
  spec.homepage = "http://postage.rubyforge.org/"
  #

  # Version
  spec.version = "0.1.4.1"
  spec.date = "2009-09-08"
  #

  # Dependencies
  spec.add_dependency "maruku"
  #

  # Manifest
  spec.files = [
  ]
  #

  spec.test_files = spec.files.select{ |path| path =~ /^test\/*test*/ }

  spec.require_paths = ["lib"]

  # Documentation
  spec.has_rdoc = true
  spec.extra_rdoc_files = [
    "README",
    "LICENSE",
    "CHANGELOG"
  ]
  spec.rdoc_options = [
    "--inline-source",
    "--line-numbers",
    "--charset", "utf8",
    "--main", "Postview",
    "--title", "Postview API Documentation"
  ]

  # RubyGems
  spec.rubyforge_project = spec.name
  spec.rubygems_version = "1.3.3"
  spec.post_install_message = <<-end_message.gsub(/^[ ]{6}/,'')
    #{'-'*78}
    #{Postage::Version}

    Thanks for use Postage.

    Please, feedback in http://github.com/hallison/postage/issues.
    #{'-'*78}
  end_message
  #
end


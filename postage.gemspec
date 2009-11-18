Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY

  #about
  spec.name = "postage"
  spec.summary = "Postage API implemented for helper handle text files for posts."
  spec.description = "Postage is an API developed for handle text files for posts for blogs or anything else."
  spec.authors = ["Hallison Batista"]
  spec.email = "email@hallisonbatista.com"
  spec.homepage = "http://postage.rubyforge.org/"
  #

  #version
  spec.version = "0.1.4.2"
  spec.date = "2009-11-18"
  #

  #dependencies
  spec.add_dependency "maruku"
  #

  #manifest
  spec.files = [
    "AUTHORS",
    "CHANGELOG",
    "COPYING",
    "README",
    "Rakefile",
    "VERSION",
    "lib/postage.rb",
    "lib/postage/about.rb",
    "lib/postage/entry.rb",
    "lib/postage/extensions.rb",
    "lib/postage/finder.rb",
    "lib/postage/post.rb",
    "lib/postage/version.rb",
    "postage.gemspec",
    "templates/post.erb",
    "test/customizations.rb",
    "test/entry_test.rb",
    "test/finder_test.rb",
    "test/fixtures/20080501-postage_test_post.ruby.postage.mkd",
    "test/fixtures/20080601-postage_test_post.ruby.postage.mkd",
    "test/fixtures/20090604-postage_test_post.ruby.postage.mkd",
    "test/fixtures/20090604143805-postage_test_post.ruby.postage.mkd",
    "test/fixtures/20090608-creating_new_post_from_test_unit.ruby.postage.test.mkd",
    "test/fixtures/entry_test.mkd",
    "test/fixtures/new_entry_test.mkd",
    "test/post_test.rb"
  ]
  #

  spec.test_files = spec.files.select{ |path| path =~ /^test\/*test*/ }

  spec.require_paths = ["lib"]

  #documentation
  spec.has_rdoc = true
  spec.extra_rdoc_files = [
    "README",
    "COPYING",
    "CHANGELOG"
  ]
  spec.rdoc_options = [
    "--inline-source",
    "--line-numbers",
    "--charset", "utf8",
    "--main", "Postview",
    "--title", "Postview API Documentation"
  ]

  #rubygems
  spec.rubyforge_project = spec.name
  spec.post_install_message = <<-end_message.gsub(/^[ ]{4}/,'')
    #{'-'*78}
    Postage v#{spec.version}

    Thanks for use Postage.

    Please, feedback in http://github.com/hallison/postage/issues.
    #{'-'*78}
  end_message
  #
end


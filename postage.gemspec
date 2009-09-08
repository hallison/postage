require 'lib/postage'

@gemspec = Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.version  = Postage::Version::tag
  spec.date     = Postage::Version::info.date

  Postage::About.info.marshal_dump.each do |info, value|
    spec.send("#{info}=", value) if spec.respond_to? "#{info}="
  end

  Postage::About.info.dependencies.each do |name, version|
    spec.add_dependency name, version
  end if Postage::About.info.dependencies

  spec.require_paths = %w[lib]
  spec.files         = Dir["{lib,tasks,test}/**/**", "Rakefile"]
  spec.test_files    = spec.files.select{ |path| path =~ /^test\/*test*/ }

  spec.has_rdoc          = true
  spec.extra_rdoc_files  = %w{README LICENSE}
  spec.rdoc_options      = %W{
    --line-numbers
    --inline-source
    --title #{Postage}
    --main README
  }
  spec.rubyforge_project = spec.name
  spec.rubygems_version  = "1.3.3"
end


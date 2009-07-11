require 'rake/packagetask'
require 'rake/gempackagetask'

def manifest_file
  File.readlines(File.join(Postage::ROOT, "MANIFEST"))
end

def manifest
  manifest_file.map do |file|
    file.strip
  end
end

def spec
  Gem::Specification.new do |spec|
    spec.platform = Gem::Platform::RUBY
    Postage::INFO.each do |info, value|
      spec.send("#{info}=", value) if spec.respond_to? "#{info}="
    end

    Postage::INFO[:dependencies].each do |name, version|
      spec.add_dependency name, version
    end

    spec.require_paths = %w[lib]
    spec.files = manifest
    spec.test_files = spec.files.select{ |path| path =~ /^test\/.*_test.rb/ }

    spec.has_rdoc = true
    spec.extra_rdoc_files = %w[README LICENSE]
    spec.add_development_dependency 'ruby-debug', '>= 0.10.3'
  
    spec.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Postage", "--main", "README"]
    spec.rubyforge_project = spec.name
    spec.rubygems_version = '1.1.1'
  end # Gem::Specification
end

def package(ext)
  "pkg/#{spec.name}-#{spec.version}.#{ext}"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end

desc "Generate MANIFEST file."
task :manifest do |file|
  File.open(File.join(Postage::ROOT, file.name.upcase), "w+") do |manifest|
    manifest.write(
      `git ls-files`.split("\n").sort.reject do |ignored|
        ignored =~ /^\./ || ignored =~ /rdoc/
      end.join("\n")
    )
  end
end

desc "Install gem file."
task :install => [ :manifest, :gem ] do
  `gem install pkg/#{spec.name}-#{spec.version}.gem`
end

desc 'Publish gem and tarball to rubyforge.org.'
task :release => [ :gem, :package] do |t|
  sh <<-end_sh.gsub(/[ ]{4}/,'')
    rubyforge add_release #{spec.name} #{spec.name} #{spec.version} #{package "gem"} &&
    rubyforge add_file    #{spec.name} #{spec.name} #{spec.version} #{package(".tar.bz2")}
  end_sh
end

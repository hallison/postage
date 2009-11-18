$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'rake/clean'
require 'lib/postage'

# Helpers
# =============================================================================

def rdoc(*args)
  @rdoc ||= if Gem.available? "hanna"
              ["hanna", "--fmt", "html", "--accessor", "option_accessor=RW"]
            else
              ["rdoc"]
            end
  @rdoc += args
  sh @rdoc.join(" ")
end

def test(*args)
  @test ||= (Gem.available? "turn") ? ["turn"] : ["testrb", "-v"]
  @test += args
  sh @test.join(" ")
end

def manifest
  @manifest ||= `git ls-files`.split.sort.reject{ |out| out =~ /^\./ || out =~ /^doc/ }
end

def history
  @history ||= `git log master --date=short --format='%d;%cd;%s;%b;'`
end

def gemspec
  @gemspec ||= Struct.new(:spec, :file).new
  @gemspec.file ||= Pathname.new("postage.gemspec")
  @gemspec.spec ||= eval @gemspec.file.read
  @gemspec
end

# Documentation
# =============================================================================

namespace :doc do

  CLOBBER << FileList["doc/*"]

  file "doc/api/index.html" => FileList["lib/**/*.rb", "README", "CHANGELOG"] do |filespec|
    rm_rf "doc"
    rdoc "--op", "doc/api",
         "--charset", "utf8",
         "--main", "'Postage'",
         "--title", "'Postage API Documentation'",
         "--inline-source",
         "--promiscuous",
         "--line-numbers",
         filespec.prerequisites.join(" ")
  end

  desc "Build API documentation (doc/api)"
  task :api => "doc/api/index.html"

  desc "Creates/updates CHANGELOG file."
  task :changelog do |spec|
    File.open("CHANGELOG", "w+") do |changelog|
      history.scan(/(.*?);(.*?);(.*?);(.*?);/m) do |tag, date, subject, content|
        tag.gsub! /[\n\( ].*?:[\) ]|,.*,.*[\)\n ]|[\)\n ]/m, ""
        tag = tag.empty? ? "v0.0.0" : "v#{tag}"
        changelog << "== #{tag} - #{date} - #{subject}\n"
        changelog << "\n#{content}\n"
      end
    end
    puts "Successfully updated CHANGELOG file"
  end

end

# RubyGems
# =============================================================================

namespace :gem do

  file gemspec.file => FileList[gemspec.spec.files] do
    when_writing "Creating #{gemspec.file}" do
      gemspec.file.open "w+" do |specfile|
        specfile << gemspec.spec.to_yaml
      end
    end
    puts "Successfully build #{gemspec.file} file"
  end

  desc "Build gem specification file #{gemspec.file}"
  task :spec => [gemspec.file.to_s]

  desc "Build gem package #{gemspec.spec.file_name}"
  task :build => :spec do
    sh "gem build #{gemspec.file}"
  end

  desc "Deploy gem package to GemCutter.org"
  task :deploy => :build do
    sh "gem push #{gemspec.spec.file_name}"
  end

  desc "Install gem package #{gemspec.spec.file_name}"
  task :install => :build do
    sh "gem install #{gemspec.spec.file_name}.gem --local"
  end

  desc "Uninstall gem package #{gemspec.spec.file_name}"
  task :uninstall do
    sh "gem uninstall #{gemspec.spec.name} --version #{gemspec.spec.version}"
  end

end

# Test
# =============================================================================

namespace :test do

  desc "Run all tests"
  task :all do
    test "test/*_test.rb"
  end

  desc "Run only test found by pattern"
  task :only, [:pattern] do |spec, args|
    test "test/#{args[:pattern]}*_test.rb"
  end

end

# Default
# =============================================================================

task :default => "test:all"


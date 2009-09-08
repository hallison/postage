require 'rake/packagetask'
require 'rake/gempackagetask'
load 'postage.gemspec'

def package(ext)
  "pkg/#{spec.name}-#{spec.version}.#{ext}"
end

Rake::GemPackageTask.new(@gemspec) do |pkg|
  pkg.need_tar_bz2 = true
end

desc "Install gem package."
task :install => [ :gem ] do
  `gem install pkg/#{Postage.specification.name}-#{Postage.specification.version}.gem --local`
end

desc "Uninstall gem package."
task :uninstall do
  `gem uninstall #{spec.name}`
end

desc 'Publish gem and tarball to rubyforge.org.'
task :release => [ :gem, :package] do |t|
  sh <<-end_sh.gsub(/^[ ]{4}/,'')
    rubyforge add_release #{spec.name} #{spec.name} #{spec.version} #{package "gem"} &&
    rubyforge add_file #{spec.name} #{spec.name} #{spec.version} #{package("tar.bz2")}
  end_sh
end


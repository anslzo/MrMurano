require "bundler/gem_tasks"

task :default => [:test]

desc "Install gem in user dir"
task :bob do
    sh %{gem install --user-install pkg/MrMurano-#{Bundler::GemHelper.gemspec.version}.gem}
end

desc "Uninstall from user dir"
task :unbob do
    sh %{gem uninstall --user-install pkg/MrMurano-#{Bundler::GemHelper.gemspec.version}.gem}
end

task :echo do
    puts "= #{Bundler::GemHelper.gemspec.version} ="
end

namespace :git do
    desc "Push only develop, master, and tags to origin"
    task :origin do
        sh %{git push origin develop}
        sh %{git push origin master}
        sh %{git push origin --tags}
    end

    desc "Push only develop, master, and tags to upstream"
    task :upstream do
        sh %{git push upstream develop}
        sh %{git push upstream master}
        sh %{git push upstream --tags}
    end
end

task :gempush do
    sh %{gem push pkg/MrMurano-#{Bundler::GemHelper.gemspec.version}.gem}
end

task :gemit do
    mrt=Bundler::GemHelper.gemspec.version
    sh %{git checkout v#{mrt}}
    Rake::Task[:build].invoke
    Rake::Task[:bob].invoke
    Rake::Task[:gempush].invoke
    sh %{git checkout develop}
end

task :wexe do
    # Need to find all dlls, because ocra isn't finding them for some reason.
    gemdir = `gem env gemdir`.chomp  # XXX can we get that without running commands?
    gemdlls = Dir[File.join(gemdir, 'extensions', '*')]
    sh %{ocra bin/mr #{gemdlls.join(' ')}}
end

desc "Prints a cmd to test this in another directory"
task :testwith do
    pwd=Dir.pwd.sub(Dir.home, '~')
    puts "ruby -I#{pwd}/lib #{pwd}/bin/mr "
end

desc 'Run RSpec'
task :test do
    Dir.mkdir("report") unless File.directory?("report")
    sh %{rspec --format html --out report/index.html --format progress}
end

#  vim: set sw=4 ts=4 :


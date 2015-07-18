require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

begin

  desc "Start a console"
  task :console do
    require 'pry'
    require 'stretchy'
    Pry.start
  end

  task c: :console
rescue LoadError
end

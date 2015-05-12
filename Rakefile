require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'README.md']
    t.options = ['-m markdown', '--extra', '--opts']
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
end

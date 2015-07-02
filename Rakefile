require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

desc "Load Stretchy in your console"
task :pry do
  require 'pry'
  require 'stretchy'

  def reload!

    files = $LOADED_FEATURES.select { |feat| feat =~ /\/stretchy\// }
    old_verbose, $VERBOSE = $VERBOSE, nil
    files.each { |file| load file }
    "Done!"
  ensure
    $VERBOSE = old_verbose
  end

  SPEC_INDEX    = 'stretchy_test'
  FIXTURE_TYPE  = 'game_dev'

  Stretchy.configure do |c|
    c.index_name = SPEC_INDEX
  end

  ARGV.clear
  Pry.start
end
task console: [:pry]
task c: [:pry]

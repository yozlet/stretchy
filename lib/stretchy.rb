require "stretchy/version"
require "logger"
require "excon"
require "elasticsearch"

Gem.find_files("stretchy/**/*.rb").each { |path| require path }

module Stretchy
  extend Configuration

end

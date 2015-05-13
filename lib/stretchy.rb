require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'

require 'stretchy/utils/configuration'
require 'stretchy/utils/client_actions'

# {include:file:README.md}

module Stretchy
  extend Stretchy::Utils::Configuration
  extend Stretchy::Utils::ClientActions
end

Gem.find_files('stretchy/**/*.rb').reject{|f| f =~ /spec/ }.each {|f| require f }

require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'

module Stretchy
end

Gem.find_files('stretchy/**/*.rb').reject{|f| f =~ /spec/ }.each {|f| require f }

Stretchy.send(:extend, Stretchy::Utils::Configuration)
Stretchy.send(:extend, Stretchy::Utils::ClientActions)
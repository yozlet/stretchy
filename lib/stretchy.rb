require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'

require 'stretchy/utils'
require 'stretchy/errors'
require 'stretchy/types'
require 'stretchy/queries'
require 'stretchy/filters'
require 'stretchy/queries'
require 'stretchy/boosts'
require 'stretchy/builders'
require 'stretchy/results'
require 'stretchy/clauses'

# {include:file:README.md}

module Stretchy
  extend Stretchy::Utils::Configuration
  extend Stretchy::Utils::ClientActions
end

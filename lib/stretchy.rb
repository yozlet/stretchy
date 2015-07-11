require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'
require 'virtus'
require 'validation'

require 'stretchy_validations'
require 'stretchy/utils'
require 'stretchy/errors'
require 'stretchy/types'
require 'stretchy/queries'
require 'stretchy/filters'
require 'stretchy/queries'
require 'stretchy/boosts'
require 'stretchy/nodes'
require 'stretchy/api'
require 'stretchy/builders'
require 'stretchy/results'
require 'stretchy/clauses'

# {include:file:README.md}

module Stretchy
  extend Utils::Configuration
  extend Utils::ClientActions

  module_function

  def api(options = {})
    Api::Base.new(options)
  end
end

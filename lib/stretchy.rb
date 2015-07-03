require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'
require 'virtus'
require 'validation'

require 'stretchy_validations'
require 'stretchy/api'
require 'stretchy/boosts'
require 'stretchy/builders'
require 'stretchy/clauses'
require 'stretchy/errors'
require 'stretchy/filters'
require 'stretchy/nodes'
require 'stretchy/queries'
require 'stretchy/results'
require 'stretchy/types'
require 'stretchy/utils'
require 'stretchy/version'

# {include:file:README.md}

module Stretchy
  extend Utils::Configuration
  extend Utils::ClientActions

  module_function

  def api(options = {})
    Api::Base.new(options)
  end
end

require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'

require 'stretchy/utils/contract'
require 'stretchy/utils/configuration'
require 'stretchy/utils/client_actions'
require 'stretchy/boosts/base'
require 'stretchy/filters/base'
require 'stretchy/queries/base'
require 'stretchy/clauses/base'
require 'stretchy/results/base'

grep_require = ->(matches){
  Dir[File.join(File.dirname(__FILE__), 'stretchy', '**', '*.rb')].each do |path|
    require path if path =~ matches
  end
}

grep_require.call(/utils/)
grep_require.call(/base/)
grep_require.call(/(?!utils|base)/)

module Stretchy

  extend Utils::Configuration
  extend Utils::ClientActions

end

require 'json'
require 'logger'
require 'excon'
require 'elasticsearch'

require 'stretchy/utils/contract'
require 'stretchy/utils/configuration'
require 'stretchy/utils/client_actions'
require 'stretchy/boosts/base'
require 'stretchy/filters/base'
require 'stretchy/queries/base'
require 'stretchy/clauses/base'

Dir[File.join(File.dirname(__FILE__), 'stretchy', '**', '*.rb')].each do |path|
  require path unless path =~ /utils/ || path =~ /base/
end

module Stretchy

  extend Utils::Configuration
  extend Utils::ClientActions

end

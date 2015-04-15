require 'json'
require 'logger'
require 'excon'
require 'elasticsearch'

Dir[File.join(File.dirname(__FILE__), 'stretchy', '**', '*.rb')].each do |path|
  require path
end

module Stretchy
  extend Configuration
  extend ClientActions

end

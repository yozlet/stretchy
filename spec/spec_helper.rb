$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'stretchy'

FIXTURE_TYPE  = 'game_dev'
FIXTURES      = {}

Dir[File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', '**', '*.json')].each do |path|
  name = File.basename(path, '.json').to_sym
  FIXTURES[name] = JSON.parse(File.read(path))
end

# LOGGER        = Logger.new(STDOUT)
# LOGGER.level  = Logger::DEBUG
MAPPING  = {
  game_dev: {
    properties: {
      coords: { type: :geo_point }
    }
  }
}

Stretchy.configure do |c|
  c.index_name = FIXTURE_TYPE
end

RSpec.configure do |config|

  config.before(:suite) do
    Stretchy.delete
    Stretchy.create
    Stretchy.mapping(Stretchy.index_name, FIXTURE_TYPE, MAPPING)
    Stretchy.refresh
    FIXTURES.each do |name, data|
      Stretchy.index(type: FIXTURE_TYPE, body: data)
    end
    Stretchy.refresh
  end

end

def fixture(name)
  return FIXTURES[name] if FIXTURES[name]
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'stretchy'
require 'awesome_print'

SPEC_INDEX    = 'stretchy_test'
FIXTURE_TYPE  = 'game_dev'
FIXTURES      = {}

Gem.find_files('**/*.json').each do |path|
  name = File.basename(path, '.json').to_sym
  FIXTURES[name] = JSON.parse(File.read(path))
end

# LOGGER        = Logger.new(STDOUT)
# LOGGER.level  = Logger::DEBUG
MAPPING  = {
  game_dev: {
    properties: {
      coords: { type: :geo_point },
      url_slug: { type: :string, index: :not_analyzed }
    }
  }
}

Stretchy.configure do |c|
  c.index_name = SPEC_INDEX
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

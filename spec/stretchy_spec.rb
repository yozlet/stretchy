require 'spec_helper'

describe Stretchy do
  it 'has a version number' do
    expect(Stretchy::VERSION).not_to be nil
  end

  it 'can be configured' do
    Stretchy.configure do |c|
      c.index_name = 'stretchy_test'
      c.url        = 'http://localhost:9200'
    end

    expect(Stretchy.index_name).to eq('stretchy_test')
    expect(Stretchy.url).to eq('http://localhost:9200')
  end
end

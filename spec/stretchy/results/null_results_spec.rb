require 'spec_helper'

describe Stretchy::Results::NullResults do

  let(:request) { Stretchy.query(type: FIXTURE_TYPE).match(location: "Japan") }

  it 'ignores optional clause param' do
    expect(described_class.new.hits.count).to eq(0)
  end

  it 'returns limit' do
    expect(subject.limit).to eq(0)
  end

  it 'returns offset' do
    expect(subject.offset).to eq(0)
  end

  it 'generates request body' do
    expect(subject.request).to eq({})
  end

  it 'generates response json' do
    expect(subject.response).to be_a(Hash)
  end

  it 'retrieves ids and converts to integers' do
    expect(subject.ids).to be_empty
  end

  it 'returns hits' do
    expect(subject.hits.count).to eq(0)
  end

  it 'returns how long the query took' do
    expect(subject.took).to eq(0)
  end

  it 'returns number of shards' do
    expect(subject.shards).to eq({})
  end

  it 'returns total results' do
    expect(subject.total).to eq(0)
  end

  it 'returns maximum query score' do
    expect(subject.max_score).to eq(0)
  end

end
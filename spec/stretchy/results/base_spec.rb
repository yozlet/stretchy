require 'spec_helper'

describe Stretchy::Results::Base do

  let(:request) { Stretchy.query(type: FIXTURE_TYPE).match(location: "Japan") }

  subject { described_class.new(request) }

  it 'accesses limit' do
    expect(subject.limit).to eq(request.get_limit)
  end

  it 'accesses offset' do
    expect(subject.offset).to eq(request.get_offset)
  end

  it 'generates request body' do
    expect(subject.request).to be_a(Hash)
  end

  it 'generates response json' do
    expect(subject.response).to be_a(Hash)
  end

  it 'retrieves ids and converts to integers' do
    expect(subject.ids).to be_a(Array)
    expect(subject.ids.count).to be > 1
    expect(subject.ids.all?{|id| id.is_a?(Numeric)}).to eq(true)
  end

  it 'returns hits' do
    expect(subject.hits.count).to be > 1
    ['_index', '_type', '_id', '_score'].each do |field|
      expect(subject.hits.first[field]).to_not be_nil
    end
  end

  it 'returns how long the query took' do
    expect(subject.took).to be > 0
  end

  it 'returns number of shards' do
    expect(subject.shards).to be_a(Hash)
  end

  it 'returns total results' do
    expect(subject.total).to eq(subject.hits.count)
  end

  it 'returns maximum query score' do
    expect(subject.max_score).to be > 0
  end

end
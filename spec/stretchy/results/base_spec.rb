require 'spec_helper'

describe Stretchy::Results::Base do

  let(:request) { Stretchy.query(type: FIXTURE_TYPE).match(location: "Japan") }
  let(:found)   { fixture(:sakurai) }

  subject { described_class.new(request) }

  it 'accesses limit' do
    expect(subject.limit).to eq(request.get_limit)
    expect(subject.limit_value).to eq(request.get_limit)
  end

  it 'accesses offset' do
    expect(subject.offset).to eq(request.get_offset)
  end

  it 'accesses current page' do
    expect(subject.current_page).to eq(request.current_page)
  end

  context 'with variable results' do
    before {  }
  end

  it 'computes total pages' do
    expect(subject.total_pages).to eq(1)

    allow(subject).to receive(:total).and_return(100)
    allow(subject).to receive(:limit).and_return(20)
    expect(subject.total_pages).to eq(5)

    allow(subject).to receive(:total).and_return(67)
    allow(subject).to receive(:limit).and_return(19)
    expect(subject.total_pages).to eq(4)
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

  it 'returns scores' do
    expect(subject.scores).to be_a(Hash)
    expect(subject.scores.count).to be > 1
    expect(subject.scores[found['id'].to_s]).to be_a(Numeric)
  end

  context 'with explanation' do
    let(:request) { Stretchy.query(type: FIXTURE_TYPE).match(location: "Japan").explain }

    it 'returns explanations' do
      expect(subject.explanations).to be_a(Hash)
      expect(subject.explanations.count).to be > 1
      expect(subject.explanations[found['id'].to_s]).to be_a(Hash)
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

  it 'returns aggregations' do
    query_with_aggs = request.aggregations(
      game_devs: {
        global: {}, 
        aggs: { 
          avg_salary: { avg: { field: :salary } }
        }
      }
    )
    aggs = described_class.new(query_with_aggs).aggregations
    expect(aggs).to be_a(Hash)
    expect(aggs['game_devs']['avg_salary']['value']).to be_a(Numeric)
  end

end
require 'spec_helper'

describe Stretchy::Clauses::Base do

  it 'initializes' do
    expect(subject).to be_a(Stretchy::Clauses::Base)
  end

  it 'builds a where context' do
    expect(subject.where).to be_a(Stretchy::Clauses::WhereClause)
  end

  it 'builds a match context' do
    expect(subject.match).to be_a(Stretchy::Clauses::MatchClause)
  end

  it 'builds a boost context' do
    expect(subject.boost).to be_a(Stretchy::Clauses::BoostClause)
  end

  it 'delegates not() correctly' do
    instance = subject.not('not match string')
    expect(instance).to be_a(Stretchy::Clauses::MatchClause)
    expect(instance.inverse?).to eq(true)
    expect(instance.match_builder.antimatches['_all']).to include('not match string')

    instance = subject.not(field: 'string')
    expect(instance).to be_a(Stretchy::Clauses::WhereClause)
    expect(instance.match_builder.antimatches[:field]).to include('string')
  end

  it 'delegates should() correctly' do
    instance = subject.should('match string')
    expect(instance).to be_a(Stretchy::Clauses::MatchClause)
    expect(instance.should?).to eq(true)
    expect(instance.match_builder.shouldmatches['_all']).to include('match string')

    instance = subject.should(field: 'string')
    expect(instance).to be_a(Stretchy::Clauses::WhereClause)
    expect(instance.match_builder.shouldmatches[:field]).to include('string')
  end

  it 'sets limit' do
    expect(subject.limit(13).get_limit).to eq(13)
    expect(subject.limit(13).limit_value).to eq(13)
  end

  it 'sets offset' do
    expect(subject.offset(29).get_offset).to eq(29)
  end

  it 'sets page' do
    expect(subject.page(2).get_offset).to eq(30)
    expect(subject.page(3, per_page: 5).get_offset).to eq(10)
    expect(subject.page(3, per_page: 5).get_limit).to eq(5)
  end

  it 'gets current page' do
    query = subject.limit(13)
    expect(query.offset(0).get_page).to eq(1)
    expect(query.offset(13).get_page).to eq(2)
    expect(query.offset(26).get_page).to eq(3)
    expect(query.offset(28).get_page).to eq(4)

    expect(query.offset(13).get_page).to eq(query.offset(13).current_page)
  end

  it 'allows setting aggregations' do
    query = subject.aggregations(
      all_products: {
          global: {}, 
          aggs: { 
            avg_price: { avg: { field: :price } }
          }
      }
    )
    
    expect(query.get_aggregations[:all_products][:global]).to be_a(Hash)
    expect(query.get_aggregations[:all_products][:aggs][:avg_price][:avg][:field]).to eq(:price)
  end

  describe 'accepts fields params with' do
    specify 'arguments' do
      query = subject.fields(:name, 'games.id')
      expect(subject.get_fields).to match_array([:name, 'games.id'])
    end

    specify 'array' do
      query = subject.fields(['games.id', :name])
      expect(subject.get_fields).to match_array([:name, 'games.id'])
    end

    specify 'nil' do
      query = subject.fields
      expect(subject.get_fields).to eq([])
    end
  end

  it 'defaults to match all query' do
    expect(described_class.new.to_search).to eq(match_all: {})
  end

  it 'is not inverse by default' do
    expect(subject.inverse?).to eq(false)
  end

  it 'produces request json via to_search' do
    expect(subject.to_search).to be_a(Hash)
  end

  it 'returns a results object' do
    expect(subject.query_results).to be_a(Stretchy::Results::Base)
    expect(subject.request).to be_a(Hash)
    expect(subject.response).to be_a(Hash)
    expect(subject.results.all?{|r| r.is_a?(Hash)}).to eq(true)
    expect(subject.ids.all?{|id| id.is_a?(Numeric)}).to eq(true)
    expect(subject.took).to be_a(Numeric)
    expect(subject.shards).to be_a(Hash)
    expect(subject.total).to be_a(Numeric)
    expect(subject.max_score).to be_a(Numeric)
  end

end
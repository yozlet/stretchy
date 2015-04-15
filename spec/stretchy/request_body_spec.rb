require 'spec_helper'

describe Stretchy::RequestBody do

  subject { Stretchy::RequestBody }

  let(:found) { fixture(:sakurai) }
  let(:not_found) { fixture(:suda) }
  let(:offset) { 0 }
  let(:limit) { 10 }
  let(:match) { Stretchy::Queries::MatchQuery.new(found['name']) }
  
  let(:filters) do
    [
      Stretchy::Filters::TermsFilter.new(field: 'name', values: [found['name']]),
      Stretchy::Filters::TermsFilter.new(field: 'salary', values: [found['salary']])
    ]
  end
  
  let(:not_filters) do
    [
      Stretchy::Filters::RangeFilter.new(
        field: 'salary',
        min: not_found['salary'] - 100,
        max: not_found['salary'] + 100
      ),
      Stretchy::Filters::TermsFilter.new(field: 'company', values: [not_found['company']])
    ]
  end
  
  let(:boosts) do
    [
      Stretchy::Boosts::FilterBoost.new(filter: filters.first, weight: 20),
      Stretchy::Boosts::GeoBoost.new(
        field: 'coords',
        offset: '1km',
        scale: '20km'
      )
    ]
  end

  def query(options = {})
    Stretchy::RequestBody.new(options).to_search[:query]
  end


  it 'uses match_all by default' do
    expect(query[:match_all]).to be_a(Hash)
  end

  it 'uses a match query when given' do
    result = query(match: match)
    expect(result[:match]['_all'][:query]).to eq(found['name'])
    expect(result[:match]['_all'][:operator]).to eq('and')
  end

  it 'uses single filter when given only one' do
    result = query(filters: Array(filters.first))
    expect(result[:filtered][:filter][:terms]['name']).to eq(Array(found['name']))
  end

  it 'ANDs filters together' do
    result = query(filters: filters)
    expect(result[:filtered][:filter][:and].first[:terms]['name']).to eq(Array(found['name']))
  end

  it 'uses Not filter when only negative conditions' do
    result = query(not_filters: Array(not_filters.last))
    expect(result[:filtered][:filter][:not][:terms]['company']).to eq(Array(not_found['company']))
  end

  it 'ANDs together NOT filters' do
    result = query(not_filters: not_filters)
    expect(result[:filtered][:filter][:not][:and].last[:terms]['company']).to eq(Array(not_found['company']))
  end

  it 'uses BOOL filter for positive and negative conditions' do
    result = query(filters: filters, not_filters: not_filters)
    expect(result[:filtered][:filter][:bool][:must].first[:terms]['name']).to eq(Array(found['name']))
    expect(result[:filtered][:filter][:bool][:must_not].last[:terms]['company']).to eq(Array(not_found['company']))
  end

  it 'uses function score query when passed boosts' do
    result = query(boosts: boosts)
    expect(result[:function_score][:functions].first[:filter][:terms]['name']).to eq(Array(found['name']))
    expect(result[:function_score][:functions].first[:weight]).to eq(20)
  end

  it 'sets offset to elastic from param' do
    result = subject.new(offset: offset).to_search
    expect(result[:from]).to eq(offset)
  end

  it 'sets limit to elastic size param' do
    result = subject.new(limit: limit).to_search
    expect(result[:size]).to eq(limit)
  end

  it 'sets explain when called' do
    result = subject.new(explain: true).to_search
    expect(result[:explain]).to eq(true)
  end

end

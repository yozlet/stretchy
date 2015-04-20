require 'spec_helper'

describe Stretchy::Queries::FunctionScoreQuery do
  subject { Stretchy::Queries::FunctionScoreQuery }

  let(:query) { Stretchy::Queries::MatchQuery.new('Rez') }
  let(:filter) { Stretchy::Filters::TermsFilter.new(field: 'name', values: ['Masahiro Sakurai'])}

  let(:filter_boost) do
    Stretchy::Boosts::FilterBoost.new(
      filter: filter,
      weight: 20
    )
  end

  let(:geo_boost) do
    Stretchy::Boosts::GeoBoost.new(
      field: 'coords',
      offset: '1km',
      scale: '20km'
    )
  end

  def get_result(*args)
    subject.new(*args).to_search[:function_score]
  end

  it 'defaults to match all query' do
    result = get_result
    expect(result[:query][:match_all]).to be_a(Hash)
  end

  it 'accepts a query' do
    result = get_result(query: query)
    expect(result[:query]).to eq(query.to_search)
  end

  it 'accepts a filter instead of a query' do
    result = get_result(filter: filter)
    expect(result[:filter]).to eq(filter.to_search)
  end

  it 'fails if passed a query and a filter' do
    expect{subject.new(query: query, filter: filter)}.to raise_error
  end

  it 'accepts an array of boosts as functions' do
    result = get_result(functions: [filter_boost, geo_boost])
    expect(result[:functions]).to include(filter_boost.to_search)
    expect(result[:functions]).to include(geo_boost.to_search)
  end

  it 'accepts simple options for function score' do
    opts = {
      boost: 5,
      max_boost: 20,
      score_mode: 'sum',
      boost_mode: 'avg',
      min_score: 1
    }
    
    result = get_result(opts)
    opts.each do |key, val|
      expect(result[key]).to eq(val)
    end
  end

  context 'raises errors for' do

    it 'invalid score mode' do
      expect{subject.new(score_mode: 'wat')}.to raise_error
    end

    it 'invalid boost mode' do
      expect{subject.new(boost_mode: 'wat')}.to raise_error
    end

    it 'invalid boost' do
      expect{subject.new(boost: 'wat')}.to raise_error
    end

    it 'invalid max boost' do
      expect{subject.new(max_boost: 'wat')}.to raise_error
    end

    it 'invalid min score' do
      expect{subject.new(min_score: 'wat')}.to raise_error
    end

    it 'invalid query' do
      expect{subject.new(query: 'wat')}.to raise_error
    end

    it 'invalid filter' do
      expect{subject.new(filter: 'wat')}.to raise_error
    end

    it 'invalid functions' do
      expect{subject.new(functions: [filter_boost, 'wat'])}.to raise_error
    end

  end

end
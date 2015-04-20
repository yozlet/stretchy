require 'spec_helper'

describe Stretchy::Queries::FilteredQuery do

  let(:filter) { Stretchy::Filters::ExistsFilter.new('name') }
  let(:query)  { Stretchy::Queries::MatchAllQuery.new }
  subject { Stretchy::Queries::FilteredQuery }

  it 'accepts a filter and query' do
    q = subject.new(query: query, filter: filter).to_search[:filtered]
    expect(q[:query][:match_all]).to be_a(Hash)
    expect(q[:filter][:exists][:field]).to eq('name')
  end

  it 'does not specify query unless given one' do
    q = subject.new(filter: filter).to_search[:filtered]
    expect(q[:query]).to be_nil
    expect(q[:filter][:exists][:field]).to eq('name')
  end

  it 'fails when filter is not given' do
    expect{subject.new}.to raise_error
  end

  it 'raises when given a non-query' do
    expect{subject.new(query: '', filter: filter)}.to raise_error
    expect{subject.new(query: query, filter: 123)}.to raise_error
  end

end
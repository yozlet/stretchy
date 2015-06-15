require 'spec_helper'

describe Stretchy::Builders::QueryBuilder do

  let(:query) { Stretchy::Queries::MatchAllQuery.new }

  def result(instance)
    instance.to_queries.first.to_search[:match]
  end

  it 'matches a field' do
    subject.add_matches('_all', 'i love kittens')
    expect(result(subject)['_all'][:query]).to eq('i love kittens')
  end

  it 'matches a field with operator option' do
    subject.add_matches('_all', 'i love kittens', operator: 'or')
    expect(result(subject)['_all'][:operator]).to eq('or')
  end

  it 'matches a field with phrase option' do
    subject.add_matches('_all', 'i love kittens', type: :phrase)
    expect(result(subject)['_all'][:type]).to eq('phrase')
  end

  it 'appends new arguments to existing fields' do
    subject.add_matches('_all', 'i love kittens')
    subject.add_matches('_all', 'and puppies')
    subject.add_matches('_all', 'and hedghogs')
    expect(result(subject)['_all'][:query]).to eq('i love kittens and puppies and hedghogs')
  end

  it 'keeps fields separate' do
    subject.add_matches('_all', 'i love kittens')
    subject.add_matches(:another_field, 'i love puppies')
    first = subject.to_queries.first.to_search
    last  = subject.to_queries.last.to_search
    expect(first[:match]['_all'][:query]).to eq('i love kittens')
    expect(last[:match]['another_field'][:query]).to eq('i love puppies')
  end

  it 'adds a query' do
    subject.add_query(query)
    expect(subject.any?).to eq(true)
    expect(subject.count).to eq(1)
    expect(subject.length).to eq(1)
    expect(subject.to_queries.first).to be_a(query.class)
  end

  it 'munges queries and params' do
    subject.add_query(query)
    subject.add_matches(:another_field, 'i love puppies')
    expect(subject.to_queries.count).to eq(2)
  end

end
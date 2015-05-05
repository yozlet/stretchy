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
  end

  it 'sets offset' do
    expect(subject.offset(29).get_offset).to eq(29)
  end

  it 'defaults to match all query' do
    expect(described_class.new.to_search).to eq(match_all: {})
  end

end
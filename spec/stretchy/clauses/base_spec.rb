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

  it 'defaults to match all query' do
    expect(described_class.new.to_search).to eq(match_all: {})
  end

end
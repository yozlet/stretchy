require 'spec_helper'

describe Stretchy::Clauses::Base do

  it 'initializes' do
    expect(subject).to be_a(Stretchy::Clauses::Base)
  end

  it 'builds a where context' do
    expect(subject.where).to be_a(Stretchy::Clauses::WhereClause)
  end

  it 'serializes to search' do
    clause = described_class.new.where(hero: 'Stretch Armstrong')
    expect(clause.to_search).to eq({:match=>{:hero=>{:query=>"Stretch Armstrong", :operator=>"and"}}})
  end

  it 'serializes with complicated params' do
    clause = described_class.new
              .where(
                hero: 'Stretch Armstrong',
                johnny: nil,
                one: ['two', 'three', 'four'],
                timerange: (Time.now - (3*60))..Time.now
              )
              .where.geo(:germany,
                distance: '27km',
                lat: 32.1,
                lng: 48.3
              )
              .where.not.geo(:norway,
                distance: '34mi',
                lat: 81.1,
                lng: 27.7
              )
              .where.not(
                bobby: true, 
                harvey: nil,
                fix: ['six', :seven, 8],
                rng: 28..32
              )
    puts JSON.pretty_generate clause.to_search
    expect(clause.to_search).to be_a(Hash)
  end

end
require 'spec_helper'

describe Stretchy::Clauses::BoostMatchClause do
  let(:base) { Stretchy::Builders::ShellBuilder.new }
  let(:default_weight) { Stretchy::Boosts::Base::DEFAULT_WEIGHT }
  let(:filter_class) { Stretchy::Filters::QueryFilter }
  let(:query_class) { Stretchy::Queries::MatchQuery }
  let(:match_clause) { Stretchy::Clauses::MatchClause }
  let(:where_clause) { Stretchy::Clauses::WhereClause }
  let(:boost_class) { Stretchy::Boosts::FilterBoost }

  subject { described_class.new(base) }

  describe 'initialize with' do
    specify 'base' do
      expect(subject).to be_a(described_class)
      expect(subject).to be_a(Stretchy::Clauses::BoostClause)
      expect(subject).to be_a(Stretchy::Clauses::Base)
    end
  end

  describe 'can match with' do

    specify 'string' do
      instance = subject.boost_match('match all string')
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'field and value parameters' do
      instance = subject.boost_match(string_field: 'string field matcher')
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost).to be_a(boost_class)
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'string and weight' do
      instance = subject.boost_match('match all string', weight: 12)
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
    end

    specify 'string, weight, and fields' do
      instance = subject.boost_match('match all string',
        weight: 12,
        type: :phrase
      )
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
      expect(boost.filter.query.type).to eq('phrase')
    end
  end

  describe 'can match fulltext' do
    specify 'string, weight, and match options' do
      instance = subject.boost.fulltext('match all string')
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      query = boost.filter.query
      expect(query.type).to eq(query_class::MATCH_TYPES.first)
      expect(query.min).to eq(match_clause::FULLTEXT_MIN)
      expect(query.slop).to eq(match_clause::FULLTEXT_SLOP)
      expect(boost.weight).to eq(Stretchy::Boosts::Base::DEFAULT_WEIGHT)
    end
  end

  it 'can match arbitrary query json' do
    instance = subject.query(foo: {bar: :baz})
    expect(instance.base.boost_builder.functions.count).to eq(1)
    boost = instance.base.boost_builder.functions.first
    expect(boost.filter).to be_a(filter_class)
    query = boost.filter.query
    expect(query).to be_a(Stretchy::Queries::ParamsQuery)
  end

  describe 'can add options' do

    specify 'not' do
      expect(subject.not.inverse?).to eq(true)
    end
  end

  describe 'can change state without adding boosts' do

    specify 'to match' do
      expect(subject.match.base.boost_builder.functions.count).to eq(0)
    end

    specify 'to where' do
      expect(subject.where.base.boost_builder.functions.count).to eq(0)
    end
  end

  describe 'cannot chain' do
    subject { described_class.new(base).match('matchstr') }

    specify 'match' do
      instance = subject.match('filtermatch')
      expect(instance).to be_a(match_clause)
      expect(instance.base.match_builder.must.matches['_all']).to include('filtermatch')
    end

    specify 'where' do
      instance = subject.where(filter_field: 27)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.terms[:filter_field]).to include(27)
    end

    specify 'range' do
      instance = subject.range(:range_field, min: 33)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.ranges[:range_field]).to be_a(Stretchy::Filters::RangeFilter)
    end

    specify 'geo' do
      instance = subject.geo(:geo_field, distance: '33km', lat: 22, lng: 47)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.geos[:geo_field]).to be_a(Stretchy::Filters::GeoFilter)
    end
  end
end

require 'spec_helper'

describe Stretchy::Clauses::BoostMatchClause do
  let(:base) { Stretchy::Builders::ShellBuilder.new }
  let(:default_weight) { Stretchy::Boosts::Base::DEFAULT_WEIGHT }
  let(:filter_class) { Stretchy::Filters::QueryFilter }
  let(:boost_class) { Stretchy::Boosts::FilterBoost }

  describe 'initialize with' do
    specify 'base' do
      instance = described_class.new(base)
      expect(instance).to be_a(described_class)
      expect(instance).to be_a(Stretchy::Clauses::BoostClause)
      expect(instance).to be_a(Stretchy::Clauses::Base)
    end

    specify 'string' do
      instance = described_class.new(base, 'match all string')
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'string and options' do
      instance = described_class.new(base, 'match all string', string_field: 'string field matcher')
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost).to be_a(boost_class)
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'string and weight' do
      instance = described_class.new(base, 'match all string', weight: 12)
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
    end

    specify 'string, weight, and fields' do
      instance = described_class.new(base, 'match all string', 
        weight: 12, 
        string_field: 'match string field'
      )
      expect(instance.base.boost_builder.functions.count).to eq(1)
      boost = instance.base.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
    end
  end

  describe 'can add options' do
    subject { described_class.new(base) }

    specify 'not' do
      expect(subject.not.inverse?).to eq(true)
    end
  end

  describe 'cannot chain' do
    subject { described_class.new(base).match('matchstr') }

    specify 'match' do
      instance = subject.match('filtermatch')
      expect(instance).to be_a(Stretchy::Clauses::MatchClause)
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
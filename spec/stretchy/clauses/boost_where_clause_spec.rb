require 'spec_helper'

describe Stretchy::Clauses::BoostWhereClause do
  let(:base) { Stretchy::Builders::ShellBuilder.new }
  let(:filter_boost) { Stretchy::Boosts::FilterBoost }
  subject { described_class.new(base) }

  describe 'initialize with' do
    specify 'base' do
      expect(subject).to be_a(described_class)
      expect(subject).to be_a(Stretchy::Clauses::BoostClause)
      expect(subject).to be_a(Stretchy::Clauses::Base)
    end
  end

  describe 'can boost params' do
    specify 'params' do
      instance = subject.boost_where(number_field: 27)
      expect(instance.base.boost_builder.functions).to include(filter_boost)
    end
  end

  describe 'can add options' do

    specify 'range' do
      instance = subject.range(:range_field, min: 88)
      expect(instance.base.boost_builder.functions).to include(filter_boost)
    end

    specify 'geo' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 88.3, lng: 22.1)
      expect(instance.base.boost_builder.functions).to include(filter_boost)
    end

    specify 'not' do
      expect(subject.not.inverse?).to eq(true)
    end
  end

  it 'can boost with arbitrary filter json' do
    instance = subject.filter(foo: {bar: :baz})
    expect(instance.base.boost_builder.functions.count).to eq(1)
    boost = instance.base.boost_builder.functions.first
    expect(boost.filter).to be_a(Stretchy::Filters::ParamsFilter)
  end

  describe 'cannot chain' do

    specify 'where' do
      instance = subject.where(filter_field: 27)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.terms[:filter_field]).to include(27)
    end

    specify 'match' do
      instance = subject.match('string')
      expect(instance).to be_a(Stretchy::Clauses::MatchClause)
      expect(instance.base.match_builder.must.matches['_all']).to include('string')
    end

    specify 'range' do
      instance = subject.range(:range_field, min: 88).range(:filter_range, max: 33)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.ranges[:filter_range]).to be_a(Stretchy::Filters::RangeFilter)
    end

    specify 'geo' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 88.3, lng: 22.1).geo(:filter_geo, distance: '35mi', lat: 22.9, lng: 82.1)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.base.where_builder.must.geos[:filter_geo]).to be_a(Stretchy::Filters::GeoFilter)
    end
  end
end

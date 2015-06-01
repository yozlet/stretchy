require 'spec_helper'

describe Stretchy::Clauses::BoostWhereClause do
  let(:base) { Stretchy::Clauses::Base.new }

  describe 'initialize with' do
    specify 'base' do
      instance = described_class.new(base)
      expect(instance).to be_a(described_class)
      expect(instance).to be_a(Stretchy::Clauses::BoostClause)
      expect(instance).to be_a(Stretchy::Clauses::Base)
    end

    specify 'params' do
      instance = described_class.new(base, number_field: 27)
      expect(instance.boost_builder.functions).to include(Stretchy::Boosts::FilterBoost)
    end
  end

  describe 'can add options' do
    subject { described_class.new(base) }

    specify 'range' do
      instance = subject.range(:range_field, min: 88)
      expect(instance.boost_builder.functions).to include(Stretchy::Boosts::FilterBoost)
    end

    specify 'geo' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 88.3, lng: 22.1)
      expect(instance.boost_builder.functions).to include(Stretchy::Boosts::FilterBoost)
    end

    specify 'not' do
      expect(subject.not.inverse?).to eq(true)
    end
  end

  describe 'cannot chain' do
    subject { described_class.new(base) }

    specify 'where' do
      instance = subject.where(filter_field: 27)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.where_builder.terms[:filter_field]).to include(27)
    end

    specify 'match' do
      instance = subject.match('string')
      expect(instance).to be_a(Stretchy::Clauses::MatchClause)
      expect(instance.match_builder.matches['_all']).to include('string')
    end

    specify 'range' do
      instance = subject.range(:range_field, min: 88).range(:filter_range, max: 33)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.where_builder.ranges[:filter_range]).to be_a(Stretchy::Types::Range)
    end

    specify 'geo' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 88.3, lng: 22.1).geo(:filter_geo, distance: '35mi', lat: 22.9, lng: 82.1)
      expect(instance).to be_a(Stretchy::Clauses::WhereClause)
      expect(instance.where_builder.geos[:filter_geo]).to include(distance: '35mi')
    end
  end
end
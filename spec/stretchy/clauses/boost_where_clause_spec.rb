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

    specify 'inverse option' do
      instance = described_class.new(base, inverse: true)
      expect(instance.inverse?).to eq(true)
    end

    specify 'params' do
      instance = described_class.new(base, number_field: 27)
      expect(instance.boost_builder.functions).to include(Stretchy::Boosts::FilterBoost)
    end

    specify 'inverse params' do
      instance = described_class.new(base, number_field: 27, inverse: true)
      expect(instance.boost_builder.functions.count).to eq(1)
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
end
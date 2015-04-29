require 'spec_helper'

describe Stretchy::Clauses::BoostMatchClause do
  let(:base) { Stretchy::Clauses::Base.new }
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

    specify 'inverse option' do
      instance = described_class.new(base, inverse: true)
      expect(instance.inverse?).to eq(true)
    end

    specify 'string' do
      instance = described_class.new(base, 'match all string')
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'string and options' do
      instance = described_class.new(base, 'match all string', string_field: 'string field matcher')
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
      expect(boost).to be_a(boost_class)
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'inverse string and options' do
      instance = described_class.new(base, 'not all string', 
        string_field: 'not field match',
        inverse: true
      )
      expect(instance.inverse?).to eq(true)
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
      expect(boost).to be_a(boost_class)
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(default_weight)
    end

    specify 'string and weight' do
      instance = described_class.new(base, 'match all string', weight: 12)
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
    end

    specify 'string, inverse, and weight' do
      instance = described_class.new(base, 'match all string', weight: 12, inverse: true)
      expect(instance.inverse?).to eq(true)
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
      expect(boost.filter).to be_a(filter_class)
      expect(boost.weight).to eq(12)
    end

    specify 'string, inverse, weight, and fields' do
      instance = described_class.new(base, 'match all string', 
        weight: 12, 
        inverse: true,
        string_field: 'match string field'
      )
      expect(instance.inverse?).to eq(true)
      expect(instance.boost_builder.functions.count).to eq(1)
      boost = instance.boost_builder.functions.first
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
end
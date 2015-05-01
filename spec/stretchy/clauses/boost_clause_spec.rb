require 'spec_helper'

describe Stretchy::Clauses::BoostClause do
  let(:base) { Stretchy::Clauses::Base.new }

  describe 'initialize with' do
    specify 'base' do
      instance = described_class.new(base)
      expect(instance).to be_a(described_class)
    end

    specify 'inverse option' do
      instance = described_class.new(base, inverse: true)
      expect(instance.inverse?).to eq(true)
    end
  end

  describe 'can add option' do
    subject { described_class.new(base) }

    specify 'random' do
      expect(subject.random(27).boost_builder.functions).to include(Stretchy::Boosts::RandomBoost)
    end

    specify 'global' do
      expect(subject.all(33).boost_builder.overall_boost).to eq(33)
    end

    specify 'max' do
      expect(subject.max(84).boost_builder.max_boost).to eq(84)
    end

    specify 'score mode' do
      expect(subject.score_mode('avg').boost_builder.score_mode).to eq('avg')
    end

    specify 'boost mode' do
      expect(subject.boost_mode('avg').boost_builder.boost_mode).to eq('avg')
    end

    specify 'not' do
      expect(subject.not.inverse?).to eq(true)
    end

    specify 'where' do
      expect(subject.where).to be_a(Stretchy::Clauses::BoostWhereClause)
    end

    specify 'match' do
      expect(subject.match).to be_a(Stretchy::Clauses::BoostMatchClause)
    end
  end
end
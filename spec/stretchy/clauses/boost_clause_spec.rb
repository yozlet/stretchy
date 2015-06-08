require 'spec_helper'

describe Stretchy::Clauses::BoostClause do
  let(:base) { Stretchy::Builders::ShellBuilder.new }
  subject    { described_class.new(base) }

  specify 'base' do
    instance = described_class.new(base)
    expect(instance).to be_a(described_class)
  end

  describe 'can add option' do

    specify 'random' do
      expect(subject.random(27).base.boost_builder.functions).to include(Stretchy::Boosts::RandomBoost)
    end

    specify 'global' do
      expect(subject.all(33).base.boost_builder.overall_boost).to eq(33)
    end

    specify 'max' do
      expect(subject.max(84).base.boost_builder.max_boost).to eq(84)
    end

    specify 'score mode' do
      expect(subject.score_mode('avg').base.boost_builder.score_mode).to eq('avg')
    end

    specify 'boost mode' do
      expect(subject.boost_mode('avg').base.boost_builder.boost_mode).to eq('avg')
    end

    specify 'where' do
      expect(subject.where).to be_a(Stretchy::Clauses::BoostWhereClause)
    end

    specify 'match' do
      expect(subject.match).to be_a(Stretchy::Clauses::BoostMatchClause)
    end

    describe 'field' do
      specify 'single field' do
        clause = subject.field(:salary)
        fn = clause.base.boost_builder.functions.first

        expect(fn).to be_a(Stretchy::Boosts::FieldValueBoost)
        expect(fn.field).to eq(:salary)
        expect(fn.modifier).to be_nil
        expect(fn.factor).to be_nil
      end

      specify 'multiple fields' do
        clause = subject.field(:salary, :number_two, :number_three)
        expect(clause.base.boost_builder.functions.count).to eq(3)
      end

      specify 'field with factor and modifier' do
        clause = subject.field(:salary, factor: 2, modifier: :log2p)
        fn = clause.base.boost_builder.functions.first
        expect(fn.factor).to eq(2)
        expect(fn.modifier).to eq(:log2p)
      end

      specify 'multiple fields with factor and modifier' do
        clause = subject.field(:salary, :number_two, :number_three, factor: 2, modifier: :log2p)
        fn = clause.base.boost_builder.functions.first
        expect(fn.factor).to eq(2)
        expect(fn.modifier).to eq(:log2p)
      end

      specify 'only with valid modifier' do
        expect{subject.field(:salary, modifier: :wat?)}.to raise_error
      end
    end

    describe 'near' do

      specify 'geo point' do
        clause = subject.near(field: :coords, lat: 23.3, lng: 28.8, scale: '10km')
        fn = clause.base.boost_builder.functions.first
        expect(fn).to be_a(Stretchy::Boosts::FieldDecayBoost)
        expect(fn.field).to eq(:coords)
        expect(fn.origin).to be_a(Stretchy::Types::GeoPoint)
        expect(fn.origin.lat).to eq(23.3)
        expect(fn.origin.lon).to eq(28.8)
        expect(fn.scale).to eq('10km')
      end

      it 'is aliased as geo' do
        clause = subject.geo(field: :coords, lat: 23.3, lng: 28.8, scale: '10km')
        fn = clause.base.boost_builder.functions.first
        expect(fn).to be_a(Stretchy::Boosts::FieldDecayBoost)
        expect(fn.origin).to be_a(Stretchy::Types::GeoPoint)
      end

      specify 'date' do
        time = Time.now
        clause = subject.near(field: :published, origin: time, scale: '3d')
        fn = clause.base.boost_builder.functions.first
        
        expect(fn).to be_a(Stretchy::Boosts::FieldDecayBoost)
        expect(fn.field).to eq(:published)
        expect(fn.origin).to eq(time)
        expect(fn.scale).to eq('3d')
      end

      specify 'number' do
        clause = subject.near(field: :rank, origin: 27, scale: 2)
        fn = clause.base.boost_builder.functions.first
        
        expect(fn).to be_a(Stretchy::Boosts::FieldDecayBoost)
        expect(fn.field).to eq(:rank)
        expect(fn.origin).to eq(27)
        expect(fn.scale).to eq(2)
      end
    end
  end

  describe 'does not chain from' do
    let(:match_builder) { Stretchy::Builders::MatchBuilder }
    let(:where_builder) { Stretchy::Builders::WhereBuilder }

    specify 'near' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :my_field, 3, {}
      )
      instance = subject.near(field: :published, origin: Time.now, scale: '3d').where(my_field: 3)
      expect(instance.base.boost_builder.functions).to include(Stretchy::Boosts::FieldDecayBoost)
    end

    specify 'random' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :my_field, 3, {}
      )
      instance = subject.random(100).where(my_field: 3)
      expect(instance.base.boost_builder.functions).to include(Stretchy::Boosts::RandomBoost)
    end
  end
end
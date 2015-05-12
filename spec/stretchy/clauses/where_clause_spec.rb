require 'spec_helper'

describe Stretchy::Clauses::WhereClause do
  let(:base) { Stretchy::Clauses::Base.new }

  context 'initializes with' do
    specify 'base' do
      instance = described_class.new(base)
      expect(instance.where_builder.any?).to eq(false)
    end

    specify 'params' do
      instance = described_class.new(base,
        field_one: 'one',
        nil_field: nil,
        range_field: 27..34,
        number_field: 86,
        symbol_field: :my_symbol
      )
      expect(instance.match_builder.matches[:field_one]).to include('one')
      expect(instance.match_builder.matchops[:field_one]).to eq('or')
      expect(instance.match_builder.matches[:symbol_field]).to include(:my_symbol)
      expect(instance.match_builder.matchops[:symbol_field]).to eq('or')
      
      expect(instance.where_builder.terms[:number_field]).to include(86)
      expect(instance.where_builder.antiexists).to include(:nil_field)
      
      expect(instance.where_builder.ranges[:range_field]).to be_a(Stretchy::Types::Range)
      expect(instance.where_builder.ranges[:range_field].min).to eq(27)
      expect(instance.where_builder.ranges[:range_field].max).to eq(34)
      
      [:shouldterms, :shouldnotterms, :shouldranges, 
       :shouldnotranges, :shouldgeos, :shouldnotgeos,
       :shouldexists, :shouldnotexists].each do |field|

        expect(instance.where_builder.send(field).any?).to eq(false)
      end
    end

    specify 'inverse option' do
      instance = described_class.new(base,
        field_one: 27,
        inverse: true
      )
      expect(instance.inverse?).to eq(true)
      expect(instance.where_builder.antiterms[:field_one]).to include(27)

      [:matches, :antimatches, :shouldmatches, :shouldnotmatches].each do |field|
        expect(instance.match_builder.send(field)[:inverse]).to be_empty
      end

      [:terms, :shouldterms, :antiterms, :shouldnotterms].each do |field|
        expect(instance.where_builder.send(field)[:inverse]).to be_empty
      end
    end

    specify 'should option' do
      instance = described_class.new(base,
        field_one: 27,
        should: true
      )
      expect(instance.should?).to eq(true)
      expect(instance.where_builder.shouldterms[:field_one]).to include(27)

      [:matches, :antimatches, :shouldmatches, :shouldnotmatches].each do |field|
        expect(instance.match_builder.send(field)[:should]).to be_empty
      end
      
      [:terms, :shouldterms, :antiterms, :shouldnotterms].each do |field|
        expect(instance.where_builder.send(field)[:should]).to be_empty
      end
    end

    specify 'tmp' do
      expect(described_class.tmp).to be_a(described_class)
    end
  end

  describe 'can add a' do

    subject { described_class.new(base) }

    specify 'geo field' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 34.3, lng: 28.2)
      expect(instance.where_builder.geos[:geo_field][:distance]).to eq('27km')
      expect(instance.where_builder.geos[:geo_field][:geo_point]).to be_a(Stretchy::Types::GeoPoint)
      expect(instance.where_builder.geos[:geo_field][:geo_point].lat).to eq(34.3)
      expect(instance.where_builder.geos[:geo_field][:geo_point].lon).to eq(28.2)
    end

    specify 'range with min' do
      instance = subject.range(:range_field, min: 88)
      expect(instance.where_builder.ranges[:range_field]).to be_a(Stretchy::Types::Range)
      expect(instance.where_builder.ranges[:range_field].min).to eq(88)
      expect(instance.where_builder.ranges[:range_field].max).to be_nil
    end

    specify 'range with max' do
      instance = subject.range(:range_field, max: 99)
      expect(instance.where_builder.ranges[:range_field]).to be_a(Stretchy::Types::Range)
      expect(instance.where_builder.ranges[:range_field].min).to be_nil
      expect(instance.where_builder.ranges[:range_field].max).to eq(99)
    end

    specify 'inverse options' do
      instance = subject.not(number_field: 27)
      expect(instance.inverse?).to eq(true)
      builder = instance.where_builder
      expect(builder.antiterms[:number_field]).to include(27)
      expect(builder.terms[:number_field]).to_not include(27)
    end

    specify 'should options' do
      instance = subject.should(number_field: 27)
      expect(instance.inverse?).to eq(false)
      builder = instance.where_builder
      expect(builder.shouldterms[:number_field]).to include(27)
      expect(builder.terms[:number_field]).to_not include(27)
      expect(builder.antiterms[:number_field]).to_not include(27)
    end

    specify 'should not options' do
      instance = subject.should.not(number_field: 27)
      expect(instance.inverse?).to eq(true)
      expect(instance.should?).to  eq(true)
      builder = instance.where_builder
      expect(builder.shouldnotterms[:number_field]).to include(27)
      expect(builder.shouldterms[:number_field]).to_not include(27)
      expect(builder.antiterms[:number_field]).to_not include(27)
      expect(builder.terms[:number_field]).to_not include(27)
    end

    specify 'should not and where options' do
      instance = subject.should.not(not_field: 27).should(should_field: 33).where(where_field: 42)
      builder = instance.where_builder
      expect(builder.terms[:where_field]).to include(42)
      expect(builder.shouldterms[:should_field]).to include(33)
      expect(builder.shouldnotterms[:not_field]).to include(27)
    end

    specify 'where not / should options' do
      instance = subject.not(not_field: 27).should(should_field: 33).not(should_not_one: 88)
                        .where.not(other_not: 42).should.not(should_not_two: 22)
      builder = instance.where_builder
      expect(builder.antiterms[:not_field]).to include(27)
      expect(builder.antiterms[:other_not]).to include(42)
      expect(builder.shouldterms[:should_field]).to include(33)
      expect(builder.shouldnotterms[:should_not_one]).to include(88)
      expect(builder.shouldnotterms[:should_not_two]).to include(22)
    end
  end

  it 'converts to boost' do
    instance = described_class.new(base,
      number_field: 27,
      string_field: 'hello',
      nil_field: nil,
      range_field: 34..99
    )
    boost = instance.to_boost
    expect(boost).to be_a(Stretchy::Boosts::FilterBoost)
  end

end
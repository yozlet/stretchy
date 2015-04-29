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
      expect(instance.match_builder.matches[:symbol_field]).to include(:my_symbol)
      expect(instance.where_builder.terms[:number_field]).to include(86)
      expect(instance.where_builder.empties).to include(:nil_field)
      expect(instance.where_builder.ranges[:range_field]).to eq(
        min: 27,
        max: 34
      )
    end

    specify 'inverse option' do
      instance = described_class.new(base,
        field_one: 27,
        inverse: true
      )
      expect(instance.inverse?).to eq(true)
      expect(instance.where_builder.antiterms[:field_one]).to include(27)
      expect(instance.where_builder.terms[:inverse]).to be_empty
      expect(instance.where_builder.antiterms[:inverse]).to be_empty
      expect(instance.match_builder.matches[:inverse]).to be_empty
      expect(instance.match_builder.antimatches[:inverse]).to be_empty
    end

    specify 'tmp' do
      expect(described_class.tmp).to be_a(described_class)
    end
  end

  describe 'can add a' do

    subject { described_class.new(base) }

    specify 'geo field' do
      instance = subject.geo(:geo_field, distance: '27km', lat: 34.3, lng: 28.2)
      expect(instance.where_builder.geos[:geo_field]).to eq(distance: '27km', lat: 34.3, lng: 28.2)
    end

    specify 'range with min' do
      instance = subject.range(:range_field, min: 88)
      expect(instance.where_builder.ranges[:range_field]).to eq(min: 88, max: nil)
    end

    specify 'range with max' do
      instance = subject.range(:range_field, max: 99)
      expect(instance.where_builder.ranges[:range_field]).to eq(min: nil, max: 99)
    end

    specify 'inverse options' do
      instance = subject.not(number_field: 27)
      expect(instance.inverse?).to eq(true)
      expect(instance.where_builder.antiterms[:number_field]).to include(27)
      expect(instance.where_builder.terms[:number_field]).to_not include(27)
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
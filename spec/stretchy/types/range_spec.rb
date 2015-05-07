require 'spec_helper'

describe Stretchy::Types::Range do

  it 'validates param presence' do
    expect{subject}.to raise_error
  end

  describe 'produces valid json output with' do

    specify 'range' do
      expect(described_class.new(23..47).to_search[:gte]).to eq(23)
      expect(described_class.new(23..47).to_search[:lte]).to eq(47)
    end

    specify 'exclusive range' do
      expect(described_class.new(23...47).to_search[:gte]).to eq(23)
      expect(described_class.new(23...47).to_search[:lte]).to eq(46)
    end

    specify 'exclusive option' do
      expect(described_class.new(23...47, exclusive: true).to_search[:gt]).to eq(23)
      expect(described_class.new(23...47, exclusive: true).to_search[:lt]).to eq(46)
    end

    specify 'exclusive min' do
      expect(described_class.new(23..47, exclusive_min: true).to_search[:gt]).to eq(23)
      expect(described_class.new(23..47, exclusive_min: true).to_search[:lte]).to eq(47)
    end

    specify 'exclusive max' do
      expect(described_class.new(23..47, exclusive_max: true).to_search[:gte]).to eq(23)
      expect(described_class.new(23..47, exclusive_max: true).to_search[:lt]).to eq(47)
    end

    describe 'a hash including' do
      specify 'min' do
        expect(described_class.new(min: 27).to_search[:gte]).to eq(27)
      end

      specify 'max' do
        expect(described_class.new(max: 27).to_search[:lte]).to eq(27)
      end

      specify 'min and max' do
        expect(described_class.new(min: 27, max: 34).to_search[:gte]).to eq(27)
        expect(described_class.new(min: 27, max: 34).to_search[:lte]).to eq(34)
      end

      specify 'exclusive' do
        expect(described_class.new(min: 27, max: 34, exclusive: true).to_search[:gt]).to eq(27)
        expect(described_class.new(min: 27, max: 34, exclusive: true).to_search[:lt]).to eq(34)
      end

      specify 'exclusive min' do
        expect(described_class.new(min: 27, max: 34, exclusive_min: true).to_search[:gt]).to eq(27)
        expect(described_class.new(min: 27, max: 34, exclusive_min: true).to_search[:lte]).to eq(34)
      end

      specify 'exclusive max' do
        expect(described_class.new(min: 27, max: 34, exclusive_max: true).to_search[:gte]).to eq(27)
        expect(described_class.new(min: 27, max: 34, exclusive_max: true).to_search[:lt]).to eq(34)
      end
    end

  end

end
require 'spec_helper'

describe Stretchy::Boosts::FieldValueBoost do

  it 'initializes with field' do
    inst = described_class.new(:my_field)
    expect(inst.field).to eq(:my_field)
  end

  it 'initializes with options' do
    inst = described_class.new(:my_field, factor: 9001, modifier: :log2p)
    expect(inst.factor).to eq(9001)
    expect(inst.modifier).to eq(:log2p)
  end

  it 'serializes options' do
    inst = described_class.new(:my_field, factor: 9001, modifier: :log2p)
    expect(inst.to_search).to eq({
      field_value_factor: {
        field: :my_field,
        factor: 9001,
        modifier: :log2p
      }
    })
  end

end
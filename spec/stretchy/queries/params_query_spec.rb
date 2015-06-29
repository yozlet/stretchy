require 'spec_helper'

describe Stretchy::Queries::ParamsQuery do

  it 'stores arbitrary json' do
    expect(described_class.new(foo: {bar: :baz}).to_search[:foo]).to eq(bar: :baz)
  end

  it 'cannot initialize with nil' do
    expect{described_class.new}.to raise_error
  end

end

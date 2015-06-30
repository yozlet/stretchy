require 'spec_helper'

describe Stretchy::Filters::ParamsFilter do
  let(:params) { Hash[foo: {bar: :baz}] }

  it 'stores arbitrary json' do
    expect(described_class.new(params).to_search[:foo]).to eq(bar: :baz)
  end

  it 'cannot initialize with nil' do
    expect{described_class.new}.to raise_error
  end

end

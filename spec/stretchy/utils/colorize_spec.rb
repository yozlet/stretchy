require 'spec_helper'

describe Stretchy::Utils::Colorize do

  it 'colorizes via instance method' do
    expect(subject.colorize("Red string", "red")).to match(/Red string/)
  end

  it 'colorizes via class method' do
    expect(described_class.red("Red String")).to match(/Red String/)
  end

  it 'references colors' do
    expect(described_class.colors).to be_a(Hash)
  end

  it 'references bg colors' do
    expect(described_class.bgs).to be_a(Hash)
  end

end
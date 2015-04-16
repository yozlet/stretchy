require 'spec_helper'

describe Stretchy::Boosts::RandomBoost do

  subject { Stretchy::Boosts::RandomBoost }
  let(:seed) { 57 }
  let(:weight) { 1.9 }

  def get_result(*args)
    subject.new(*args).to_search
  end

  it 'returns json for random boost' do
    result = get_result(seed, weight)
    expect(result[:random_score][:seed]).to eq(seed)
    expect(result[:weight]).to eq(weight)
  end

  it 'has optional weight param' do
    result = get_result(seed)
    expect(result[:random_score][:seed]).to eq(seed)
    expect(result[:weight]).to eq(Stretchy::Boosts::RandomBoost::DEFAULT_WEIGHT)
  end

  xit 'raises error unless seed and weight are numeric' do
    expect{subject.new('wat')}.to raise_error
    expect{subject.new(seed, 'wat')}.to raise_error
  end

end
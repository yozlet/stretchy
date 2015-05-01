require 'spec_helper'

describe Stretchy::Boosts::FilterBoost do

  subject { Stretchy::Boosts::FilterBoost }
  let(:exists_filter) { Stretchy::Filters::ExistsFilter.new('name') }
  let(:terms_filter) { Stretchy::Filters::TermsFilter.new('name', 'Masahiro Sakurai') }
  let(:weight) { 20 }

  def get_result(*args)
    subject.new(*args).to_search
  end

  it 'is a boost' do
    expect(subject.new(filter: exists_filter)).to be_a(Stretchy::Boosts::Base)
  end

  it 'returns json for filter boost' do
    result = get_result(filter: exists_filter, weight: weight)
    expect(result[:filter]).to eq(exists_filter.to_search)
    expect(result[:weight]).to eq(weight)
  end

  it 'defaults to weight 1.2' do
    result = get_result(filter: exists_filter)
    expect(result[:filter]).to eq(exists_filter.to_search)
    expect(result[:weight]).to eq(Stretchy::Boosts::FilterBoost::DEFAULT_WEIGHT)
  end

  it 'raises error unless filter is appropriate type' do
    expect{subject.new(filter: 'wat')}.to raise_error(Stretchy::Errors::ContractError)
  end

  it 'raises error unless weight is numeric' do
    expect{subject.new(filter: terms_filter, weight: 'wat')}.to raise_error(Stretchy::Errors::ContractError)
  end
end
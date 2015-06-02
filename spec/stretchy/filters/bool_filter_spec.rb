require 'spec_helper'

describe Stretchy::Filters::BoolFilter do

  let(:terms_filter) { Stretchy::Filters::TermsFilter.new('name', 'Masahiro Sakurai') }
  let(:range_filter) do
    Stretchy::Filters::RangeFilter.new(
      'salary',
      min: 100,
      max: 200
    )
  end
  let(:geo_filter) do
    Stretchy::Filters::GeoFilter.new(
      'coords',
      '50km',
      lat: 35.0117,
      lng: 135.7683
    )
  end

  subject { Stretchy::Filters::BoolFilter }

  def get_result(*args)
    subject.new(*args).to_search[:bool]
  end

  it 'takes a must param' do
    result = get_result(must: terms_filter, must_not: nil)
    expect(result[:must].first).to eq(terms_filter.to_search)
    expect(result[:must_not]).to be_nil
  end

  it 'takes a must_not param' do
    result = get_result(must: nil, must_not: terms_filter)
    expect(result[:must_not].first).to eq(terms_filter.to_search)
    expect(result[:must]).to be_nil
  end

  it 'takes a should param' do
    result = get_result(must: nil, must_not: nil, should: terms_filter)
    expect(result[:should].first).to eq(terms_filter.to_search)
    expect(result[:must]).to be_nil
    expect(result[:must_not]).to be_nil
  end

  it 'takes arrays as parameters' do
    result = get_result(must: [terms_filter, range_filter], must_not: [geo_filter])
    expect(result[:must].first).to eq(terms_filter.to_search)
    expect(result[:must].last).to eq(range_filter.to_search)
    expect(result[:must_not].first).to eq(geo_filter.to_search)
  end

  it 'should param is optional' do
    result = get_result(must: terms_filter, must_not: nil)
    expect(result[:must].first).to eq(terms_filter.to_search)
  end

  it 'raises error unless at least one param is present' do
    expect{subject.new}.to raise_error
  end

  it 'raises error unless params are filters' do
    expect{subject.new(must: ['wat'], must_not: ['nope'], should: ['wtf'])}.to raise_error
    expect{subject.new(must: 'wat', must_not: 123)}.to raise_error
  end

  it 'must param is optional' do
    result = get_result(must_not: terms_filter)
    expect(result[:must_not].first).to eq(terms_filter.to_search)
  end

  it 'must_not param is optional' do
    result = get_result(must: terms_filter)
    expect(result[:must].first).to eq(terms_filter.to_search)
  end

end
require 'spec_helper'

describe Stretchy::Filters::NotFilter do

  subject { Stretchy::Filters::NotFilter }
  let(:terms_filter) { Stretchy::Filters::TermsFilter.new(field: 'name', values: ['Masahiro Sakurai'])}
  let(:range_filter) do
    Stretchy::Filters::RangeFilter.new(
      field: 'salary',
      min: 100,
      max: 200
    )
  end

  def get_result(*args)
    subject.new(*args).to_search[:not]
  end

  it 'accepts a filter param' do
    result = get_result(terms_filter)
    expect(result).to eq(terms_filter.to_search)
  end

  it 'accepts an array of filters' do
    result = get_result([terms_filter, range_filter])
    expect(result[:and].first).to eq(terms_filter.to_search)
    expect(result[:and].last).to eq(range_filter.to_search)
  end

  xit 'accepts filter arguments' do
    result = get_result(terms_filter, range_filter)
    expect(result[:and].first).to eq(terms_filter.to_search)
    expect(result[:and].last).to eq(range_filter.to_search)
  end

  xit 'raises exception unless at least one filter is passed' do
    expect{subject.new}.to raise_error
  end

end
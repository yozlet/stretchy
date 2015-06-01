require 'spec_helper'

describe Stretchy::Filters::AndFilter do
  subject { Stretchy::Filters::AndFilter }
  let(:terms_filter) { Stretchy::Filters::TermsFilter.new('name', 'Masahiro Sakurai') }
  let(:range_filter) do
    Stretchy::Filters::RangeFilter.new(
      'salary',
      min: 100,
      max: 200
    )
  end

  def get_result(*args)
    subject.new(*args).to_search[:and]
  end

  it 'accepts an array of filters' do
    result = get_result([terms_filter, range_filter])
    expect(result).to include(terms_filter.to_search)
    expect(result).to include(range_filter.to_search)
  end

  it 'accepts a single filter' do
    result = get_result(terms_filter)
    expect(result).to include(terms_filter.to_search)
  end

  it 'accepts argument filters' do
    result = get_result(terms_filter, range_filter)
    expect(result).to include(terms_filter.to_search)
    expect(result).to include(range_filter.to_search)
  end

  it 'validates that arguments are filters' do
    expect{subject.new([terms_filter, 'wat'])}.to raise_error
  end

end
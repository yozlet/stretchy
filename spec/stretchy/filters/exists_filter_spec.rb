require 'spec_helper'

describe Stretchy::Filters::ExistsFilter do

  let(:field) { 'name' }
  subject { Stretchy::Filters::ExistsFilter }

  def get_result(*args)
    subject.new(*args).to_search[:exists]
  end

  it 'returns json for exists filter' do
    result = get_result(field)
    expect(result[:field]).to eq(field)
  end

  it 'raises an error unless field is non-empty string' do
    expect{subject.new}.to raise_error
    expect{subject.new('')}.to raise_error
    expect{subject.new([''])}.to raise_error
  end

end
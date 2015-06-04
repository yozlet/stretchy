require 'spec_helper'

describe Stretchy::Queries::MatchQuery do
  subject { Stretchy::Queries::MatchQuery }

  let(:string) { 'plz match this' }

  def get_result(*args)
    subject.new(*args).to_search[:match]
  end

  it 'defaults to match any field' do
    result = get_result(string: string)
    expect(result['_all'][:query]).to eq(string)
  end

  it 'allows matching a specific field' do
    result = get_result(string: string, field: 'name')
    expect(result['name'][:query]).to eq(string)
  end

  it 'allows specifying a different operator' do
    result = get_result(string: string, operator: 'and')
    expect(result['_all'][:operator]).to eq('and')
  end

  it 'validates elastic operators' do
    expect{subject.new(string: string, operator: 'wtf')}.to raise_error
  end

  it 'validates field presence' do
    expect{subject.new(string: string, field: '')}.to raise_error
  end

end
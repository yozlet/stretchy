require 'spec_helper'

describe Stretchy::Queries::MatchQuery do
  subject { Stretchy::Queries::MatchQuery }

  let(:string) { 'plz match this' }

  def get_result(*args)
    subject.new(*args).to_search[:match]
  end

  it 'defaults to match any field using AND operator' do
    result = get_result(string)
    expect(result['_all'][:query]).to eq(string)
    expect(result['_all'][:operator]).to eq('and')
  end

  it 'allows matching a specific field' do
    result = get_result(string, field: 'name')
    expect(result['name'][:query]).to eq(string)
  end

  it 'allows specifying a different operator' do
    result = get_result(string, operator: 'or')
    expect(result['_all'][:operator]).to eq('or')
  end

  it 'validates elastic operators' do
    expect{subject.new(string, operator: 'wtf')}.to raise_error
  end

  it 'validates field presence' do
    expect{subject.new(string, field: '')}.to raise_error
  end

  xit 'allows matching multiple field / string combinations' do
    result = subject.new(name: string, company: 'Aperture Science').to_search[:match]
    expect(result[:name][:query]).to eq(string)
    expect(result[:company][:query]).to eq('Aperture Science')
  end

end
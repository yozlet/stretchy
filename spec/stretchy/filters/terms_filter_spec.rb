require 'spec_helper'

describe Stretchy::Filters::TermsFilter do

  subject { Stretchy::Filters::TermsFilter }
  let(:field) { 'name' }
  let(:values) { ['Masahiro Sakurai', 'Goichi Suda'] }

  def get_result(*args)
    subject.new(*args).to_search[:terms]
  end

  it 'returns json for terms filter' do
    result = get_result(field, values)
    expect(result[field]).to be_a(Array)
    expect(result[field].first).to eq(values.first)
  end

  it 'takes a single value as param' do
    result = get_result(field, values.first)
    expect(result[field]).to be_a(Array)
    expect(result[field].first).to eq(values.first)
  end

  it 'takes a hash as param' do
    result = get_result(field_one: ['one', 'two'], field_two: ['three', 'four'])
    expect(result[:field_one]).to eq(['one', 'two'])
    expect(result[:field_two]).to eq(['three', 'four'])
  end

  it 'raises error for invalid types' do
    expect{subject.new(field: '', values: 'wat')}.to raise_error
  end

  it 'raises error unless at least one value present' do
    expect{subject.new(field: field, values: [])}.to raise_error
  end
end
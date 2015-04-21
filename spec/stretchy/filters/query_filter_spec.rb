require 'spec_helper'

describe Stretchy::Filters::QueryFilter do

  subject { Stretchy::Filters::QueryFilter }
  let(:query) { Stretchy::Queries::MatchQuery.new('Masahiro Sakurai') }
  let(:match_query) { Stretchy::Queries::MatchQuery.new('Smash Bros', field: 'games') }

  def get_result(*args)
    subject.new(*args).to_search[:query]
  end

  it 'accepts a filter' do
    result = get_result(query)
    expect(result).to eq(query.to_search)
  end

  it 'raises error unless query is appropriate type' do
    expect{subject.new}.to raise_error
    expect{subject.new('wat')}.to raise_error
    expect{subject.new(0)}.to raise_error
  end

  xit 'combines an array of queries' do
    result = get_result([query, match_query])
    expect(result[:query][:dis_max]).to be_a(Hash)
  end

end
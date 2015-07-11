require 'spec_helper'

describe Stretchy::Queries::BoolQuery do

  let(:match_all) { Stretchy::Queries::MatchAllQuery.new }
  let(:match)     { Stretchy::Queries::MatchQuery.new('match this string') }
  let(:not_match) { Stretchy::Queries::MatchQuery.new('not this string') }

  subject { described_class.new(must: match_all) }

  it 'instantiates' do
    expect{subject}.to_not raise_error
  end

end
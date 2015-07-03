require 'spec_helper'

describe Stretchy::Nodes::BoolQuery do

  let(:match_all) { Stretchy::Nodes::MatchAllQuery.new }
  let(:match)     { Stretchy::Nodes::MatchQuery.new('match this string') }
  let(:not_match) { Stretchy::Nodes::MatchQuery.new('not this string') }

  subject { described_class.new(must: match_all) }

  it 'instantiates' do
    expect{subject}.to_not raise_error
  end

end

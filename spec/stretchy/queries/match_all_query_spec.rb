require 'spec_helper'

describe Stretchy::Queries::MatchAllQuery do

  it 'returns a match all hash' do
    expect(subject.to_search).to eq({ match_all: {} })
  end

end
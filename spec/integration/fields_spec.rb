require 'spec_helper'

describe 'fields' do

  subject { Stretchy.query(index: SPEC_INDEX, type: FIXTURE_TYPE) }

  it 'returns without source when called with nil' do
    result = subject.fields.results.first
    expect(result.keys).to match_array(['_id', '_type', '_index', '_score'])
  end

  it 'returns fields when specified' do
    result = subject.fields(:salary, 'games.title').results.first
    expect(result.keys).to match_array(['_id', '_type', '_index', '_score', 'salary', 'games'])
    expect(result['games'].keys).to match_array(['title'])
  end

  it 'returns fields specified in array' do
    result = subject.fields([:salary, 'games.title']).results.first
    expect(result.keys).to match_array(['_id', '_type', '_index', '_score', 'salary', 'games'])
    expect(result['games'].keys).to match_array(['title'])
  end

end
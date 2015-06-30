require 'spec_helper'

describe 'fulltext searching' do

  subject          { Stretchy.query(type: FIXTURE_TYPE) }
  let(:found)      { fixture(:sakurai) }
  let(:not_found)  { fixture(:mizuguchi) }

  it 'finds results in order' do
    res = subject.fulltext('Game Musician').ids
    expect(res.index(found['id'])).to be > res.index(not_found['id'])
  end

  it 'must match at least one terms' do
    res = subject.fulltext('Developer').ids
    expect(res).to match_array([found['id']])
  end

  it 'allows adding arbitrary json queries' do
    res = subject.query(multi_match: { query: 'smash', fields: ['games.title', 'bio'] }).ids
    expect(res).to include(found['id'])
    expect(res).to_not include(not_found['id'])
  end

  it 'chains arbitrary json queries' do
    res = subject.match.not.query(multi_match: { query: 'rez', fields: ['games.title', 'bio'] }).ids
    expect(res).to include(found['id'])
    expect(res).to_not include(not_found['id'])
  end

end

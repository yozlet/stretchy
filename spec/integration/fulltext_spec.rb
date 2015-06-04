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

end
require 'spec_helper'

describe 'boosts' do

  subject { Stretchy.query(index: SPEC_INDEX, type: FIXTURE_TYPE).boost }
  let(:found)      { fixture(:sakurai) }
  let(:not_found)  { fixture(:mizuguchi) }

  it 'can boost with arbitrary query json' do
    res = subject.query(multi_match: { query: 'smash', fields: ['games.title', 'bio'] })
    fn = res.to_search[:function_score][:functions].first[:filter]
    expect(fn[:query][:multi_match]).to_not be_empty
    expect(res.ids).to include(found['id'])
  end

  it 'can boost with arbitrary filter json' do
    res = subject.filter(term: { company: 'nintendo' })
    fn = res.to_search[:function_score][:functions].first[:filter]
    expect(fn[:term]).to_not be_empty
    expect(res.ids).to include(found['id'])
  end

end

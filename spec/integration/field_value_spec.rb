require 'spec_helper'

describe 'boosting by field value' do

  let(:found)      { fixture(:sakurai) }
  let(:not_found)  { fixture(:mizuguchi) }

  subject { Stretchy.query(index: SPEC_INDEX, type: FIXTURE_TYPE) }

  it 'boosts by who has the highest salary' do
    ids = subject.boost.field(:salary).ids
    expect(ids.index(found['id'])).to be < ids.index(not_found['id'])
  end

end
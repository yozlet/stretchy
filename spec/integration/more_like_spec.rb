require 'spec_helper'

describe 'more like this query' do

  let(:doc) { fixture(:sakurai) }
  let(:found) { fixture(:mizuguchi) }
  let(:loose) { Hash[
    minimum_should_match: 1,
    min_term_freq: 1,
    min_doc_freq: 1
  ]}

  subject { Stretchy.query(index: SPEC_INDEX, type: FIXTURE_TYPE) }

  def check(params)
    query = subject.more_like(loose.merge(params))
    expect(query.ids).to include(found['id'])    
  end

  it 'finds with document ids' do
    check(ids: doc['id'])
  end

  it 'finds with doc specifications' do
    check(docs: [
      { '_index' => SPEC_INDEX, '_type' => FIXTURE_TYPE, '_id' => doc['id'] }
    ])
  end

  it 'finds via like_text' do
    check(like_text: doc['bio'])
  end


end
require 'spec_helper'

describe 'terms' do

  subject          { Stretchy.query(type: FIXTURE_TYPE) }
  let(:found)      { fixture(:sakurai) }
  let(:not_found)  { fixture(:mizuguchi) }
  let(:max_time)   { Time.parse(found['first_game']) }
  let(:min_time)   { max_time - (3*60) }
  let(:time_range) { min_time..max_time }

  it 'finds documents by fulltext terms' do
    res = subject.where.terms(url_slug: found['url_slug'])
    expect(res.ids).to include(found['id'])
  end

  it 'finds documents without specified terms' do
    res = subject.where.not.terms(url_slug: not_found['url_slug'])
    expect(res.ids).to include(found['id'])
  end

  it 'scores documents by terms' do
    res = subject.should.terms(url_slug: [found['url_slug']])
    expect(res.ids).to match_array([found['id']])
  end

  it 'finds documents by boolean terms' do
    res = subject.where(is_sakurai: true)
    expect(res.ids).to include(found['id'])
    expect(res.ids).to_not include(not_found['id'])
  end

  it 'finds by arbitrary json terms' do
    res = subject.filter(term: { company: 'nintendo' })
    expect(res.ids).to include(found['id'])
    expect(res.ids).to_not include(not_found['id'])
  end

end

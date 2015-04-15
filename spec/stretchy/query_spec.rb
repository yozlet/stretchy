require 'spec_helper'

describe Stretchy::Query do

  let(:found)     { fixture(:sakurai) }
  let(:not_found) { fixture(:mizuguchi) }

  subject { Stretchy::Query.new(type: FIXTURE_TYPE) }

  def check_results(search)
    expect(search.ids).to include(found['id'])
    expect(search.ids).to_not include(not_found['id'])
  end

  it 'finds documents with an all search' do
    expect(subject.ids).to include(found['id'])
    expect(subject.ids).to include(not_found['id'])
  end

  it 'finds only documents matching query string' do
    check_results subject.match(found['name'])
  end

  it 'finds search strings from sub-objects' do
    check_results subject.match(found['games'].first['title'])
  end

  it 'finds documents not matching query' do
    check_results subject.not_match(not_found['name'])
  end

  it 'finds only documents matching location buckets' do
    check_results subject.where('games.id' => [1])
  end

  it 'finds found not matching location buckets' do
    check_results subject.not_where('games.id' => [8])
  end

  it 'finds documents within a numeric range' do
    check_results subject.range(field: :salary, min: 850000, max: 950000)
  end

  it 'finds documents outside a numeric range' do
    check_results subject.not_range(field: :salary, min: 400000, max: 500000)
  end

  it 'finds only documents within distance' do
    check_results subject.geo(
      lat: found['coords']['lat'] + 0.001, 
      lng: found['coords']['lon'] + 0.001,
      distance: '1km'
    )
  end

  it 'finds only documents outside distance' do
    check_results subject.not_geo(
      lat: not_found['coords']['lat'] + 0.0001,
      lng: not_found['coords']['lon'] + 0.0001,
      distance: '1km'
    )
  end

  it 'AND searches with multiple terms' do
    # TERMS filters are not analyzed - need to change text TERMS to query MATCHes
    check_results(subject.match(found['name'])
      .where(
        'games.id'  => [found['games'].first['id']],
        'salary'    => [found['salary']]
      )
    )
  end

  it 'boosts based on nearness to location' do
    ids = subject.boost_geo(
      lat:    found['coords']['lat'],
      lng:    found['coords']['lon'],
      decay:  0.5,
      scale:  '20km',
      weight: 5
    ).ids
    expect(ids).to include(found['id'])
    expect(ids).to include(not_found['id'])
    expect(ids.index(found['id'])).to be < ids.index(not_found['id'])
  end

  it 'boosts based on filter matches' do
    ids = subject.boost_where('games.id' => [found['games'].first['id']]).ids
    expect(ids).to include(found['id'])
    expect(ids).to include(not_found['id'])
    expect(ids.index(found['id'])).to be < ids.index(not_found['id'])
  end

  it 'boosts with a random score' do
    # just testing that the random score filter doesn't fail
    # testing that it randomizes is kind of a black box
    # so highly likely to fail intermittently
    ids = subject.boost_random(found['id']).ids
    expect(ids).to include(found['id'])
    expect(ids).to include(not_found['id'])
  end

  it 'boosts based on multiple factors' do
    search = subject
      .boost_geo(lat: found['coords']['lat'] + 0.001, lng: found['coords']['lon'] + 0.001)
      .boost_where('games.id' => [not_found['games'].first['id']], weight: 900)
    
    expect(search.ids).to include(found['id'])
    expect(search.ids).to include(not_found['id'])
    expect(search.ids.index(not_found['id'])).to be < search.ids.index(found['id'])
  end

  it 'does a big honkin query with all the bells and whistles' do
    search = subject
      .match(found['name'])
      .where('games.id' => [found['games'].first['id']])
      .geo(lat: found['coords']['lat'], lng: found['coords']['lon'])
      .boost_where('games.platforms' => [found['games'].first['platforms'].first])
      .boost_geo(lat: found['coords']['lat'], lng: found['coords']['lon'])
    check_results search
  end

end

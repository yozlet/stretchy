require 'spec_helper'

describe Stretchy do
  it 'has a version number' do
    expect(Stretchy::VERSION).not_to be nil
  end

  # most config methods are called in spec_helper
  # so we've already verified they work

  it 'has a singleton client' do
    expect(Stretchy.client).to be_a(Elasticsearch::Transport::Client)
    expect(Stretchy.client.object_id).to eq(Stretchy.client.object_id)
  end

  it 'passes from and size arguments correctly' do
    expect(Stretchy.client).to receive(:search).with(
      index: Stretchy.index_name, 
      type: FIXTURE_TYPE, 
      body: {:query=>{:match_all=>{}}},
      explain: true,
      size: 20,
      from: 1
    )

    Stretchy.search(
      type: FIXTURE_TYPE,
      body: {query: Stretchy::Queries::MatchAllQuery.new.to_search},
      explain: true,
      from: 1,
      size: 20
    )
  end

  context 'saves you a LOT of typing' do
    let(:found)      { fixture(:sakurai) }
    let(:max_time)   { Time.parse(found['first_game']) }
    let(:min_time)   { max_time - (3*60) }
    let(:time_range) { min_time..max_time }

    specify 'on ridiculous giant queries' do
      clause = Stretchy.query(type: FIXTURE_TYPE)
                .limit(20)
                .offset(1)
                .match('all_match')
                .match(match_field: 'match_field_string')
                .match.not('all_not_match')
                .match.not(not_match_field: 'not_match_field_string')
                .where(
                  must_string_field: 'must_string',
                  does_not_exist_field: nil,
                  must_terms: [:must_symbol_in_array, 9001, 'must_string_in_array_terms'],
                  must_time_range: time_range
                )
                .where.range(:min_field, min: 9000)
                .where.range(:max_field, max: 150000)
                .where.geo(:coords,
                  distance: '27km',
                  lat: found['coords']['lat'],
                  lng: found['coords']['lon']
                )
                .where.not.geo(:coords,
                  distance: '34mi',
                  lat: 85.3,
                  lng: 172.1
                )
                .where.not(
                  does_exist_field: nil,
                  must_not_string_field: 'must_not_string',
                  must_not_terms: ['must_not_string_in_array', :must_not_symbol_in_array, 1001],
                  must_not_range: 28..32
                )
                .boost.where(
                  boost_nil_field: nil,
                  boost_string_field: 'boost_string',
                  boost_terms: ['boost_string_term', :boost_symbol_term, 2150],
                  boost_range_term: 47..59,
                  weight: 1.3
                )
                .boost.where.not(
                  boost_not_nil: nil,
                  boost_not_string: 'boost_not_string',
                  boost_not_terms: ['boost_not_string_term', 2299, :boost_not_symbol_term],
                  boost_not_range_term: 45..53,
                  weight: 1.5
                )
                .boost.where.geo(:coords,
                  distance: '51mi',
                  lat: 33.9,
                  lng: 141.8,
                  weight: 0.5
                )
                .boost.where.not.geo(:coords,
                  distance: '38mi',
                  lat: 22.8,
                  lng: 41.3
                )
                .boost.where.range(:boost_range_field, min: 99, max: 150)
                .boost.where.range(:boost_min_field, min: 34)
                .boost.where.range(:boost_max_field, max: 9999)
                .boost.where.not.range(:boost_not_range_field, min: 800, max: 950)
                .boost.where.not.range(:boost_not_min_field, min: 131)
                .boost.where.not.range(:boost_not_max_field, max: 100)
                .boost.match('boost_match_any')
                .boost.match(boost_match_field: 'boost_match_field_string')
                .boost.match.not('boost_not_match_any')
                .boost.match.not(boost_match_not_field: 'boost_match_not_string')
      
      result = clause.request
      pp [:request, result]
      # puts JSON.pretty_generate clause.to_search
      expect(clause.results).to be_a(Array)

      filtered_query = result[:query][:function_score][:query][:filtered]
      
      query = filtered_query[:query][:bool][:must]
      expect(query).to include(match: { '_all' => { query: 'all_match', operator: 'and' }})
      expect(query).to include(match: { match_field: { query: 'match_field_string', operator: 'and' }})
      expect(query).to include(match: { must_string_field: { query: 'must_string', operator: 'or' }})
      expect(query).to include(match: { 
        must_terms: { 
          query: 'must_symbol_in_array must_string_in_array_terms', 
          operator: 'or' 
        }
      })

      not_query = result[:query][:function_score][:query][:filtered][:query][:bool][:must_not]
      expect(not_query).to include(match: {'_all' => { query: 'all_not_match', operator: 'and'}})
      expect(not_query).to include(match: {not_match_field: { query: 'not_match_field_string', operator: 'and'}})
      expect(not_query).to include(match: {must_not_string_field: { query: 'must_not_string', operator: 'or'}})
      expect(not_query).to include(match: {
        must_not_terms: { 
          query: 'must_not_string_in_array must_not_symbol_in_array', 
          operator: 'or'
        }
      })

      must = filtered_query[:filter][:bool][:must]
      expect(must).to include(terms: {must_terms: [9001]})
      
      expect(must).to include(range: {
        must_time_range: { 
          gte: min_time,
          lte: max_time
        }
      })
      
      expect(must).to include(range: {
        min_field: {
          gte: 9000
        }
      })

      expect(must).to include(range: {
        max_field: {
          lte: 150000
        }
      })

      expect(must).to include(geo_distance: {
        distance: '27km',
        coords: {
          lat: found['coords']['lat'],
          lon: found['coords']['lon']
        }
      })

      must_not = filtered_query[:filter][:bool][:must_not]
      expect(must_not).to include(terms: {
        must_not_terms: [1001]
      })

      expect(must_not).to include(range: {
        must_not_range: {
          gte: 28,
          lte: 32
        }
      })

      expect(must_not).to include(geo_distance: {
        distance: '34mi',
        coords: {
          lat: 85.3,
          lon: 172.1
        }
      })

      boosts = result[:query][:function_score][:functions]
      expect(boosts.any?).to eq(true)

      expect(boosts).to include(
        filter: {
          query: {
            match: {
              '_all' => {
                query: 'boost_match_any',
                operator: 'and'
              }
            }
          }
        },
        weight: 1.2
      )

      expect(boosts).to include(
        filter: {
          query: {
            filtered: {
              query: {
                bool: {
                  must: [
                    {
                      match: {
                        boost_string_field: {
                          query: 'boost_string',
                          operator: 'or'
                        }
                      }
                    },
                    {
                      match: {
                        boost_terms: {
                          query: 'boost_string_term boost_symbol_term',
                          operator: 'or'
                        }
                      }
                    }
                  ]
                }
              },
              filter: {
                bool: {
                  must: [
                    {
                      terms: {
                        boost_terms: [2150]
                      }
                    },
                    {
                      range: {
                        boost_range_term: {
                          gte: 47,
                          lte: 59
                        }
                      }
                    }
                  ],
                  must_not: [
                    {
                      exists: {
                        field: 'boost_nil_field'
                      }
                    }
                  ]
                }
              }
            }
          }
        },
        weight: 1.3
      )
      
    end
  end
end

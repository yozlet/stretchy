require 'spec_helper'

module Stretchy
  describe Collector do
    let(:sakurai_url) {
      Node.new(:term_filter, {
        term: {
          url_slug: 'masahiro-sakurai'
        }
      })
    }

    let(:mizuguchi_url) {
      Node.new(:term_filter, {
        term: {
          url_slug: 'tetsuya-mizuguchi'
        }
      })
    }

    let(:sakurai_name) {
      Node.new(:match_query, {
        match: {
          name: 'sakurai'
        }
      })
    }

    let(:mizuguchi_name) {
      Node.new(:match_query, {
        match: {
          name: 'mizuguchi'
        }
      })
    }

    it 'compiles term nodes' do
      subject.nodes << sakurai_url
      subject.nodes << mizuguchi_url
      expect(subject.to_search).to eq(
        filtered: {
          filter: {
            bool: {
              must: [
                sakurai_url.json,
                mizuguchi_url.json
              ]
            }
          }
        }
      )
    end

    it 'compiles term and match nodes' do
      subject.nodes << sakurai_url
      subject.nodes << sakurai_name
      expect(subject.to_search).to eq(
        query: {
          filtered: {
            query: {
              match: {
                name: 'sakurai'
              }
            },
            filter: {
              term: {
                url_slug: 'masahiro-sakurai'
              }
            }
          }
        }
      )
    end

  end
end

require 'spec_helper'

module Stretchy
  describe API do

    it 'makes a filtered query' do
      json = subject.where(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(
        query: { filtered: { filter: {term: {url_slug: 'masahiro-sakurai'}}}}
      )
    end

    it 'does multiple filters' do
      json = subject.where(url_slug: 'masahiro-sakurai', is_sakurai: true).json
      expect(json).to eq(
        query: { filtered: { filter: { bool: {
          must: [
            {term: {url_slug:   'masahiro-sakurai'}},
            {term: {is_sakurai: true}},
          ]
        }}}}
      )
    end

    it 'does a query and filter' do
      json = subject.fulltext(name: 'sakurai')
                    .where(url_slug: 'masahiro-sakurai', is_sakurai: true)
                    .json
      expect(json).to eq(
        query: { filtered: {
          query: { match: { name: 'sakurai' }},
          filter: { bool: {
            must: [
              {term: {url_slug:   'masahiro-sakurai'}},
              {term: {is_sakurai: true}},
            ]
          }
        }}}
      )
    end

    it 'does a not filter' do
      result = { query: { filtered: { filter: { bool: {
          must_not: [
            {term: {url_slug:   'masahiro-sakurai'}}
          ]
      }}}}}

      json = subject.where.not(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(result)

      json = subject.not.where(url_slug: 'masahiro-sakurai').json
      expect(json).to eq(result)
    end

    it 'does a query, not query, not filter' do
      result = { query: { filtered: {
        query: { bool: {
          must: [{match: { name: 'sakurai' }}],
          must_not: [{match: {name: 'mizuguchi'}}]
        }},
        filter: { bool: {
          must_not: [{term: {url_slug: 'tetsuya-mizuguchi'}}]
        }}
      }}}

      json = subject.fulltext(name: 'sakurai')
                    .fulltext.not(name: 'mizuguchi')
                    .where.not(url_slug: 'tetsuya-mizuguchi')
                    .json
      expect(json).to eq(result)
    end

    it 'does a should query' do
      result = { query: { bool: { should: [ {match: {name: 'sakurai'}}]}}}
      json = subject.fulltext.should(name: 'sakurai').json
      expect(json).to eq(result)
    end

    it 'handles complex stuff' do
      results = {:query=>{:filtered=>{:query=>{:bool=>{:must=>[{:match=>{:name=>"sakurai"}}], :must_not=>[{:match=>{:name=>"mizuguchi"}}], :should=>[{:match=>{:company=>"nintendo"}}]}}, :filter=>{:bool=>{:must=>[{:term=>{:url_slug=>"masahiro-sakurai"}}], :must_not=>[{:term=>{:url_slug=>"tetsuya-mizuguchi"}}], :should=>[{:term=>{:is_sakurai=>true}}]}}}}}

      json = subject.fulltext(name: 'sakurai')
             .fulltext.not(name: 'mizuguchi')
             .fulltext.should(company: 'nintendo')
             .where(url_slug: 'masahiro-sakurai')
             .where.not(url_slug: 'tetsuya-mizuguchi')
             .where.should(is_sakurai: true)
             .json
      expect(json).to eq(results)
    end

  end
end

require 'spec_helper'

describe Stretchy::Queries::MoreLikeThisQuery do
  let(:fields) { [:name] }
  let(:docs) { [
    {
      '_index' => SPEC_INDEX,
      '_type' => FIXTURE_TYPE,
      '_id' => 1,
      'ignored' => :ignored_field
    },
    {
      '_index' => SPEC_INDEX,
      '_type' => FIXTURE_TYPE,
      '_id' => 2,
      not_used: 'not used'
    }
  ] }

  describe 'initializes with' do
    specify 'like_text' do
      expect(described_class.new(fields: fields, like_text: 'this is a string').like_text).to eq('this is a string')
    end

    specify 'docs' do
      instance = described_class.new(fields: fields, docs: docs)
      expect(instance.docs.first).to eq('_index' => SPEC_INDEX, '_type' => FIXTURE_TYPE, '_id' => 1)
    end

    specify 'ids' do
      instance = described_class.new(fields: fields, ids: [1,2])
      expect(instance.ids).to eq([1,2])
    end
  end

  describe 'produces json for' do
    specify 'like_text' do
      json = described_class.new(fields: fields, like_text: 'this is a string').to_search[:more_like_this]
      expect(json[:like_text]).to eq('this is a string')
    end

    specify 'docs' do
      json = described_class.new(fields: fields, docs: docs).to_search[:more_like_this]
      expect(json[:docs].first).to eq(
        '_index' => SPEC_INDEX,
        '_type' => FIXTURE_TYPE,
        '_id' => 1
      )
    end

    specify 'ids' do
      json = described_class.new(fields: fields, ids: [1,2]).to_search[:more_like_this]
      expect(json[:ids]).to eq([1,2])
    end

    specify 'attributes' do
      json = described_class.new(
        fields: fields,
        ids: [1,2],
        max_query_terms: 20,
        max_doc_freq: 5,
        min_word_length: 3
      ).to_search[:more_like_this]

      expect(json[:max_query_terms]).to eq(20)
      expect(json[:max_doc_freq]).to eq(5)
      expect(json[:min_word_length]).to eq(3)
    end
  end

end
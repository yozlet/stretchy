require 'spec_helper'

describe Stretchy::Builders::MatchBuilder do

  let(:result) { subject.build.to_search }

  it 'instantiates' do
    expect(subject).to be_a(described_class)
  end

  it 'matches a term' do
    subject.matches[:fieldname] = ['one']
    expect(result[:match][:fieldname]).to eq(query: 'one', operator: 'and')
  end

  context 'when generating a bool query' do
    let(:result) { subject.build.to_search[:bool] }

    it 'matches several fields' do
      subject.matches[:fieldname] = ['one', 'two']
      subject.matches[:other]     = ['three']
      expect(result[:must].first[:match][:fieldname]).to eq(query: 'one two', operator: 'and')
      expect(result[:must].last[:match][:other]).to      eq(query: 'three',   operator: 'and')
    end

    it 'excludes matches' do
      subject.antimatches[:fieldname] = ['one']
      expect(result[:must_not].first[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    it 'matches should terms' do
      subject.shouldmatches[:fieldname] = ['one']
      expect(result[:should].first[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    it 'excludes should terms' do
      subject.shouldnotmatches[:fieldname] = ['one']
      should_not = result[:should].first[:bool][:must_not].first
      expect(should_not[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    context 'with all options' do

      before do
        subject.matches[:matchfield]                = ['match', 'this']
        subject.antimatches[:anti_field]            = ['do not match this']
        subject.shouldmatches[:should_field]        = ['should match']
        subject.shouldnotmatches[:should_not_field] = ['should', 'not', :match]
      end

      it 'produces expected json' do
        expect(result[:must].first[:match][:matchfield]).to eq(query: 'match this', operator: 'and')
        expect(result[:must_not].first[:match][:anti_field]).to eq(query: 'do not match this', operator: 'and')
        shoulds = result[:should].first[:bool]
        expect(shoulds[:must].first[:match][:should_field]).to eq(query: 'should match', operator: 'and')
        expect(shoulds[:must_not].first[:match][:should_not_field]).to eq(query: 'should not match', operator: 'and')
      end

      it 'uses matchops to determine operator' do
        subject.matchops[:matchfield] = 'or'
        subject.antimatchops[:anti_field] = 'or'
        subject.shouldmatchops[:should_field] = 'or'
        subject.shouldnotmatchops[:should_not_field] = 'or'

        expect(result[:must].first[:match][:matchfield]).to eq(query: 'match this', operator: 'or')
        expect(result[:must_not].first[:match][:anti_field]).to eq(query: 'do not match this', operator: 'or')
        
        shoulds = result[:should].first[:bool]
        expect(shoulds[:must].first[:match][:should_field]).to eq(query: 'should match', operator: 'or')
        expect(shoulds[:must_not].first[:match][:should_not_field]).to eq(query: 'should not match', operator: 'or')
      end

    end
  end
end
require 'spec_helper'

describe Stretchy::Builders::MatchBuilder do

  let(:result) { subject.to_query.to_search }

  it 'instantiates' do
    expect(subject).to be_a(described_class)
    expect(subject.any?).to eq(false)
  end

  it 'matches a term' do
    subject.add_matches(:fieldname, 'one')
    expect(result[:match][:fieldname]).to eq(query: 'one', operator: 'and')
  end

  context 'when generating a bool query' do
    let(:result) { subject.to_query.to_search[:bool] }

    it 'matches several fields' do
      subject.add_matches(:fieldname, ['one', 'two'])
      subject.add_matches(:other, ['three'])
      expect(result[:must].first[:match][:fieldname]).to eq(query: 'one two', operator: 'and')
      expect(result[:must].last[:match][:other]).to      eq(query: 'three',   operator: 'and')
    end

    it 'excludes matches' do
      subject.add_matches(:fieldname, 'one', inverse: true)
      expect(result[:must_not].first[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    it 'matches should terms' do
      subject.add_matches(:fieldname, 'one', should: true)
      expect(result[:should].first[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    it 'excludes should terms' do
      subject.add_matches(:fieldname, 'one', inverse: true, should: true)
      should_not = result[:should].first[:bool][:must_not].first
      expect(should_not[:match][:fieldname]).to eq(query: 'one', operator: 'and')
    end

    context 'with all options' do

      it 'produces expected json' do
        subject.add_matches(:matchfield, ['match', 'this'])
        subject.add_matches(:anti_field, ['do not match this'], inverse: true)
        subject.add_matches(:should_field, ['should match'], should: true)
        subject.add_matches(:should_not_field, ['should', 'not', :match], should: true, inverse: true)
        
        expect(result[:must].first[:match][:matchfield]).to eq(query: 'match this', operator: 'and')
        expect(result[:must_not].first[:match][:anti_field]).to eq(query: 'do not match this', operator: 'and')
        shoulds = result[:should].first[:bool]
        expect(shoulds[:must].first[:match][:should_field]).to eq(query: 'should match', operator: 'and')
        expect(shoulds[:must_not].first[:match][:should_not_field]).to eq(query: 'should not match', operator: 'and')
      end

      it 'uses matchops to determine operator' do
        subject.add_matches(:matchfield, ['match', 'this'], or: true)
        subject.add_matches(:anti_field, ['do not match this'], inverse: true, or: true)
        subject.add_matches(:should_field, ['should match'], should: true, or: true)
        subject.add_matches(:should_not_field, ['should', 'not', :match], should: true, inverse: true, or: true)

        expect(result[:must].first[:match][:matchfield]).to eq(query: 'match this', operator: 'or')
        expect(result[:must_not].first[:match][:anti_field]).to eq(query: 'do not match this', operator: 'or')
        
        shoulds = result[:should].first[:bool]
        expect(shoulds[:must].first[:match][:should_field]).to eq(query: 'should match', operator: 'or')
        expect(shoulds[:must_not].first[:match][:should_not_field]).to eq(query: 'should not match', operator: 'or')
      end

    end
  end
end
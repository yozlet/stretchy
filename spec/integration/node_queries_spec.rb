require 'spec_helper'

module Stretchy
  describe 'the api' do

    let(:found)     { fixture(:sakurai) }
    let(:not_found) { fixture(:mizuguchi) }

    subject { Stretchy.api(indices: [SPEC_INDEX], types: [FIXTURE_TYPE]) }

    after(:each) do
      expect(subject.result_ids).to include(found['id'])
      expect(subject.result_ids).to_not include(not_found['id'])
    end

    it 'can construct a node' do
      subject.match('Masahiro')
    end

    it 'can search by field' do
      subject.match(title: 'Developer')
    end

    it 'can search by multiple fields' do
      subject.match('_all' => 'Masahiro', title: 'Developer')
    end

    it 'can search by terms' do
      subject.where(is_sakurai: true)
    end

    it 'can search by multiple terms' do
      subject.where(is_sakurai: true, salary: 900000)
      pp subject.to_search
    end

    it 'can search by query and filter' do
      subject.where(is_sakurai: true).match(title: 'Developer')
    end

  end
end

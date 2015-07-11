require 'spec_helper'

module Stretchy
  module Api

    describe Base do

      it 'initializes with tree' do
        expect(subject.root).to be_a(Nodes::Base)
        expect(subject.current).to eq(subject.root)
      end

      it 'can add a query node' do
        expect(subject.current).to receive(:add_query).with(Nodes::MatchQuery)
        subject.match("phrase")
      end

      it 'can add multiple query nodes' do
        expect(subject.current).to receive(:add_query).twice.with(Nodes::MatchQuery)
        subject.match({field_one: 'phrase', field_two: 'other'})
      end

    end

  end
end

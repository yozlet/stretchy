require 'spec_helper'

module Stretchy
  module Nodes

    describe Root do

      it 'can add a new query' do
        subject.add_query(:new_query)
        expect(subject.query).to eq(:new_query)
      end

      it 'calls add_query if query already present' do
        first_node  = Base.new
        second_node = Base.new
        expect(first_node).to receive(:add_query).with(second_node, {})
        described_class.new(query: first_node).add_query(second_node)
      end

      it 'serializes with options' do
        params = {
          from: 2,
          size: 3,
          explain: true
        }
        expect(described_class.new(params).to_search).to eq(params)
      end

    end

  end
end

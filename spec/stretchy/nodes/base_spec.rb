require 'spec_helper'

module Stretchy
  module Nodes

    describe Base do

      it 'initializes with parent' do
        first = described_class.new
        second = described_class.new(parent: first)
        expect(second.parent).to eq(first)
      end

      it 'removes parent from to_search' do
        expect(subject.to_search).to eq({})
      end

    end

  end
end

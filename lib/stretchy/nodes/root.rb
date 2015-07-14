require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class Root < Base

      attribute :query,   Base
      attribute :from,    Integer
      attribute :size,    Integer
      attribute :explain, Axiom::Types::Boolean
      attribute :index,   Array, default: []
      attribute :type,    Array, default: []

      def add_query(node, options = {})
        if query
          @query = query.add_query(node, options)
        else
          @query        = node
          @query.parent = self
        end
        @query
      end

      def add_filter(node, options = {})
        if query
          @query = query.add_filter(node, options)
        else
          @query = FilteredQuery.new(parent: self, filter: node)
        end
        @query
      end

      def to_search
        super(reject: :query).merge(
          body:  { query: query.to_search },
          index: index.join(','),
          type:  type.first
        )
      end

    end
  end
end

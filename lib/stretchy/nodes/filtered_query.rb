require 'stretchy/queries/base'

module Stretchy
  module Nodes
    class FilteredQuery < Base

      delegate [:add_query]  => :query
      delegate [:add_filter] => :filter

      attribute :query,  Base
      attribute :filter, Nodes::Base

      validations do
        rule :query,  type: Base
        rule :filter, type: Nodes::Base
      end

      def node_type
        :query
      end

      def to_search
        json = {}
        json[:query]  = @query.to_search  if query
        json[:filter] = @filter.to_search if filter
        { filtered: json }
      end

      def add_query(node, options = {})
        if query
          query.add_query(node, options)
        else
          @query = node
        end
      end

      def add_filter(node, options = {})
        if filter
          filter.add_filter(node, options)
        else
          @filter = node
        end
      end
    end
  end
end

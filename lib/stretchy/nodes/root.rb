require 'stretchy/nodes/base'
require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    class Root < Base

      attribute :query,   Queries::Base
      attribute :from,    Numeric
      attribute :size,    Numeric
      attribute :fields,  Array

      validations do
        rule :query, type: {classes: Queries::Base, required: true}
      end

      def to_search
        json_attributes
      end

      def add_query(node, options = {})
        return @query = node                  unless query
        return @query = query.add_query(node, options = {}) if query.respond_to?(:add_query)
        @query        = BoolQuery.new(must: [query, node])
      end

      def add_filter(node, options = {})
        return @query = query.add_filter(node, options = {}) if query.respond_to?(:add_filter)
        @query        = FilteredQuery.new(query: query, filter: node)
      end

      def add_boost(node, options = {})
        return @query = query.add_boost(node, options = {}) if query.respond_to?(:add_boost)
        @query        = FunctionScoreQuery.new(query: query, functions: [node])
      end

    end
  end
end

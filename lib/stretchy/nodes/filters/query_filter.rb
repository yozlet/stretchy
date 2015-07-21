require 'stretchy/nodes/filters/base'
require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Filters
      class QueryFilter < Base

        attribute :query, Queries::Base

        validations do
          rule :query, type: {classes: Queries::Base}
        end

        def add_query(node, options = {})
          if query.respond_to?(:add_query)
            @query = query.add_query(node, options)
          else
            @query = BoolQuery.new(must: [query])
            query.add_query(node, options)
          end
        end

        def add_filter(node, options = {})
          if query.respond_to?(:add_filter)
            @query = query.add_filter(node, options)
          else
            @query = FilteredQuery.new(query: query)
            @query.add_filter(node, options)
          end
        end

        def to_search
          {
            query: @query.to_search
          }
        end
      end
    end
  end
end

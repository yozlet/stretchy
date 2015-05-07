require 'stretchy/filters/base'
require 'stretchy/queries/base'

module Stretchy
  module Filters
    class QueryFilter < Base

      contract :query, type: Stretchy::Queries::Base

      def initialize(query)
        @query = query
        validate!
      end

      def to_search
        {
          query: @query.to_search
        }
      end
    end
  end
end

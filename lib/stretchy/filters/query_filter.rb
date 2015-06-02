require 'stretchy/filters/base'
require 'stretchy/queries/base'

module Stretchy
  module Filters
    class QueryFilter < Base

      attribute :query, Queries::Base

      validations do
        rule :query, type: {classes: Queries::Base}
      end

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

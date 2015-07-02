require 'stretchy/ast/base'

module Stretchy
  module Filters
    class QueryFilter < Base

      attribute :query, Base

      validations do
        rule :query, type: {classes: Base}
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

module Stretchy
  module Filters
    class AndFilter < Base

      contract filters: {type: Stretchy::Filters::Base, array: true}

      def initialize(filters)
        @filters = Array(filters)
        validate!
      end

      def to_search
        {
          and: @filters.map(&:to_search)
        }
      end

    end
  end
end

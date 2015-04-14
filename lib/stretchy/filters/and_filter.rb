module Search
  module Filters
    class AndFilter

      def initialize(filters)
        @filters = Array(filters)
      end

      def to_search
        {
          and: @filters.map(&:to_search)
        }
      end

    end
  end
end

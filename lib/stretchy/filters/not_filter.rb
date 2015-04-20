module Stretchy
  module Filters
    class NotFilter < Base

      contract :filter, type: Base

      def initialize(filters)
        filters = Array(filters)

        if filters.count == 1
          @filter = filters.first
        else
          @filter = AndFilter.new(filters)
        end

        validate!
      end

      def to_search
        { not: @filter.to_search }
      end
    end
  end
end

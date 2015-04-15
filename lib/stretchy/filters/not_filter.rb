module Stretchy
  module Filters
    class NotFilter

      def initialize(filters)
        filters = Array(filters)

        if filters.count == 1
          @filter = filters.first
        else
          @filter = AndFilter.new(filters)
        end
      end

      def to_search
        { not: @filter.to_search }
      end
    end
  end
end

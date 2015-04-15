module Stretchy
  module Filters
    class RangeFilter
      def initialize(field:, min:, max:)
        @field = field
        @min   = min
        @max   = max
      end

      def to_search
        range = {}
        range[:gte] = @min if @min
        range[:lte] = @max if @max
        {
          range: {
            @field => range
          }
        }
      end
    end
  end
end

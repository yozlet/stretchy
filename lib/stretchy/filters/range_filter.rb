module Stretchy
  module Filters
    class RangeFilter < Base

      contract field: {type: :field},
                 min: {type: [Numeric, Time]},
                 max: {type: [Numeric, Time]}

      def initialize(options = {})
        @field = options[:field]
        @min   = options[:min]
        @max   = options[:max]
        validate!
        require_one(min: @min, max: @max)
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

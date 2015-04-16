module Stretchy
  module Boosts
    class FilterBoost

      DEFAULT_WEIGHT = 1.2

      def initialize(filter:, weight: DEFAULT_WEIGHT)
        @filter = filter
        @weight = weight
      end

      def to_search
        {
          filter: @filter.to_search,
          weight: @weight
        }
      end
    end
  end
end

module Stretchy
  module Boosts
    class FilterBoost < Base

      DEFAULT_WEIGHT = 1.2

      contract filter: {type: Stretchy::Filters::Base},
               weight: {type: Numeric}

      def initialize(filter:, weight: DEFAULT_WEIGHT)
        @filter = filter
        @weight = weight
        validate!
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

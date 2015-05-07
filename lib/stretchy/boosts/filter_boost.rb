require 'stretchy/boosts/base'
require 'stretchy/filters/base'

module Stretchy
  module Boosts
    class FilterBoost < Base

      attr_reader :filter, :weight

      contract filter: {type: Stretchy::Filters::Base},
               weight: {type: Numeric}

      def initialize(options = {})
        @filter = options[:filter]
        @weight = options[:weight] || DEFAULT_WEIGHT
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

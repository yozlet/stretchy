require 'stretchy/boosts/base'
require 'stretchy/filters/base'

module Stretchy
  module Boosts
    class FilterBoost < Base

      attribute :filter
      attribute :weight, Numeric, default: DEFAULT_WEIGHT

      validations do
        rule :filter, type: {classes: Filters::Base}
        rule :weight, type: {classes: Numeric}
      end

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

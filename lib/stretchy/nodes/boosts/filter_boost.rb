require 'stretchy/nodes/boosts/base'
require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Boosts
      class FilterBoost < Base

        attribute :filter
        attribute :weight, Numeric, default: DEFAULT_WEIGHT

        validations do
          rule :filter, type: Filters::Base
          rule :weight, type: Numeric
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
end

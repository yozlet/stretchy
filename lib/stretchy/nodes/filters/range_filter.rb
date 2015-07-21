require 'stretchy/nodes/filters/base'
require 'stretchy/nodes/types/range'

module Stretchy
  module Nodes
    module Filters
      class RangeFilter < Base

        attribute :field
        attribute :range, Types::Range

        validations do
          rule :field, field: { required: true }
          rule :range, type:  Types::Range
        end

        def to_search
          {
            range: {
              @field => @range.to_search
            }
          }
        end
      end
    end
  end
end

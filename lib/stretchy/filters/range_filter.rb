require 'stretchy/filters/base'
require 'stretchy/types/range'

module Stretchy
  module Filters
    class RangeFilter < Base

      contract field: {type: :field, required: true},
               range: {type: Types::Range, required: true}

      def initialize(field, range_options)
        @field = field
        @range = Types::Range.new(range_options)
        validate!
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

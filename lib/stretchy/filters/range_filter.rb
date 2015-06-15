require 'stretchy/filters/base'
require 'stretchy/types/range'

module Stretchy
  module Filters
    class RangeFilter < Base

      attribute :field
      attribute :range, Types::Range

      validations do
        rule :field, field: { required: true }
        rule :range, type: {classes: Types::Range}
      end

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

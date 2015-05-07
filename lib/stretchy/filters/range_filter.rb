require 'stretchy/filters/base'
require 'stretchy/types/range'

module Stretchy
  module Filters
    class RangeFilter < Base

      contract field: {type: :field, required: true},
               range: {type: Stretchy::Types::Range, required: true}

      def initialize(options = {})
        @field = options[:field]
        @range = options[:stretchy_range] || Stretchy::Types::Range.new(options)
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

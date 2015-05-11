require 'stretchy/filters/base'

module Stretchy
  module Filters
    class NotFilter < Base

      attr_reader :filters

      contract :filters, { type: Base, array: true, required: true }

      def initialize(*filters)
        @filters = Array(filters).flatten
        validate!
      end

      def filter
        if @filters.count > 1
          AndFilter.new(@filters)
        else
          @filters.first
        end
      end

      def to_search
        { not: filter.to_search }
      end
    end
  end
end

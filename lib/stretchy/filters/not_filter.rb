require 'stretchy/filters/base'

module Stretchy
  module Filters
    class NotFilter < Base

      attribute :filters, Array[Base]

      validations do
        rule :filters, type: { classes: Base, array: true }
        rule :filters, :not_empty
      end

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

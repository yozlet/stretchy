require 'stretchy/filters/base'

module Stretchy
  module Filters
    class OrFilter < Base

      attribute :filters, Array[Base]
      validations do
        rule :filters, type: {classes: Base, array: true}
      end

      def initialize(*args)
        @filters = args.flatten
        validate!
      end

      def to_search
        {
          or: @filters.map(&:to_search)
        }
      end

    end
  end
end

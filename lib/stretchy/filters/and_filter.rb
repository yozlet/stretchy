require 'stretchy/filters/base'

module Stretchy
  module Filters
    class AndFilter < Base

      attribute :filters
      validations do
        rule :filters, :not_empty
        rule :filters, type: {classes: Filters::Base, array: true}
      end

      def initialize(*args)
        @filters = args.flatten
        validate!
      end

      def to_search
        {
          and: @filters.map(&:to_search)
        }
      end

    end
  end
end

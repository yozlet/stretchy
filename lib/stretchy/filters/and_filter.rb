require 'stretchy/filters/base'

module Stretchy
  module Filters
    class AndFilter < Base

      contract filters: {type: Stretchy::Filters::Base, array: true}

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

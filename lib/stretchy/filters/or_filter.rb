module Stretchy
  module Filters
    class OrFilter < Base

      contract filters: {type: Base, array: true}

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

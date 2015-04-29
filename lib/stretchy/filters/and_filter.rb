module Stretchy
  module Filters
    class AndFilter < Base

      contract filters: {type: Stretchy::Filters::Base, array: true}

      def initialize(*args)
        if args.count == 1 && args.first.is_a?(Array)
          @filters = args.first
        else
          @filters = args
        end
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

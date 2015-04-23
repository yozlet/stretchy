module Stretchy
  module Clauses
    class Base

      attr_accessor :where_builder, :boost_builder, :aggregate_builder

      def initialize(base = nil)
        if base
          @where_builder = base.where_builder
          @boost_builder = base.boost_builder
          @aggregate_builder = base.aggregate_builder
        else
          @where_builder = @boost_builder = @aggregate_builder = nil
        end
      end

      def where(options = {})
        WhereClause.new(self, options)
      end

      def to_search
        @where_builder.to_search
      end

    end
  end
end
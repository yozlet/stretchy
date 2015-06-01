module Stretchy
  module Builders
    class MatchBuilder

      attr_accessor :must, :must_not, :should, :should_not

      def initialize
        @must       = QueryBuilder.new
        @must_not   = QueryBuilder.new
        @should     = QueryBuilder.new
        @should_not = QueryBuilder.new
      end

      def any?
        must.any? || must_not.any? || should.any? || should_not.any?
      end

      def add_matches(field, matches, options = {})
        builder_from_options(options).add_matches(field, matches, options)
      end

      def to_query
        return Stretchy::Queries::MatchAllQuery.new unless any?

        if use_bool?
          bool_query
        else
          must.to_query.first
        end
      end

      private

        def builder_from_options(options = {})
          if options[:inverse] && options[:should]
            should_not
          elsif options[:inverse]
            must_not
          elsif options[:should]
            should
          else
            must
          end
        end
        
        def use_bool?
          must.count > 1 || must_not.any? || should.any? || should_not.any?
        end

        def bool_query
          Stretchy::Queries::BoolQuery.new(
            must:     must.to_query,
            must_not: must_not.to_query,
            should:   build_should
          )
        end

        def build_should
          if should.count > 1 || should_not.any?
            Stretchy::Queries::BoolQuery.new(
              must:     should.to_query,
              must_not: should_not.to_query
            )
          else
            should.to_query.first
          end
        end

    end
  end
end
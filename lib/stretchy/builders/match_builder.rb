module Stretchy
  module Builders
    class MatchBuilder

      attr_accessor :matches, :antimatches, :shouldmatches, :shouldnotmatches

      def initialize
        @matches          = Hash.new { [] }
        @antimatches      = Hash.new { [] }
        @shouldmatches    = Hash.new { [] }
        @shouldnotmatches = Hash.new { [] }
      end

      def any?
        @matches.any? || @antimatches.any? || @shouldmatches.any? || @shouldnotmatches.any?
      end

      def build
        return Stretchy::Queries::MatchAllQuery.new unless any?

        if @matches.count > 1   || @antimatches.any? || 
           @shouldmatches.any?  || @shouldnotmatches.any?
          
          bool_query
        else
          field, strings = @matches.first
          Stretchy::Queries::MatchQuery.new(field: field, string: strings.join(' '))
        end
      end

      def bool_query
        Stretchy::Queries::BoolQuery.new(
          must:     to_queries(@matches),
          must_not: to_queries(@antimatches),
          should:   build_should
        )
      end

      def build_should
        if @shouldnotmatches.any?
          Stretchy::Queries::BoolQuery.new(
            must:     to_queries(@shouldmatches),
            must_not: to_queries(@shouldnotmatches)
          )
        else
          to_queries(@shouldmatches)
        end
      end

      private

        def to_queries(matches)
          matches.map do |field, strings|
            Stretchy::Queries::MatchQuery.new(field: field, string: strings.join(' '))
          end
        end

    end
  end
end
module Stretchy
  module Builders
    class MatchBuilder

      attr_accessor :matches,           :matchops, 
                    :antimatches,       :antimatchops,
                    :shouldmatches,     :shouldmatchops,
                    :shouldnotmatches,  :shouldnotmatchops

      def initialize
        @matches           = Hash.new { [] }
        @matchops          = Hash.new { 'and' }
        
        @antimatches       = Hash.new { [] }
        @antimatchops      = Hash.new { 'and' }
        
        @shouldmatches     = Hash.new { [] }
        @shouldmatchops    = Hash.new { 'and' }
        
        @shouldnotmatches  = Hash.new { [] }
        @shouldnotmatchops = Hash.new { 'and' }
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
          to_queries(@matches, @matchops).first
        end
      end

      def bool_query
        Stretchy::Queries::BoolQuery.new(
          must:     to_queries(@matches, @matchops),
          must_not: to_queries(@antimatches, @antimatchops),
          should:   build_should
        )
      end

      def build_should
        if @shouldnotmatches.any?
          Stretchy::Queries::BoolQuery.new(
            must:     to_queries(@shouldmatches, @shouldmatchops),
            must_not: to_queries(@shouldnotmatches, @shouldnotmatchops)
          )
        else
          to_queries(@shouldmatches, @shouldmatchops)
        end
      end

      private

        def to_queries(matches, operators)
          matches.map do |field, strings|
            Stretchy::Queries::MatchQuery.new(
              field:    field,
              string:   strings.join(' '),
              operator: operators[field]
            )
          end
        end

    end
  end
end
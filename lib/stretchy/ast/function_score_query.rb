require 'stretchy/ast/base'
require 'stretchy/ast/bool_query'
require 'stretchy/ast/bool_filter'

module Stretchy
  module AST
    class FunctionScoreQuery < Base

      SCORE_MODES = %w(multiply sum avg first max min)
      BOOST_MODES = %w(multiply replace sum avg max min)

      attribute :functions,   Array[Base], default: []
      attribute :query,       Base,        default: BoolQuery.new
      attribute :filter,      Base,        default: BoolFilter.new
      attribute :score_mode,  String
      attribute :boost_mode,  String
      attribute :min_score,   Float
      attribute :max_boost,   Float
      attribute :boost,       Float

      validations do
        rule :functions,  type: {classes: Base, array: true}
        rule :query,      type: Base
        rule :filter,     type: Base
        rule :score_mode, inclusion: {in: SCORE_MODES}
        rule :boost_mode, inclusion: {in: BOOST_MODES}
        rule :min_score,  type: Numeric
        rule :max_boost,  type: Numeric
        rule :boost,      type: Numeric
      end

      def simplify
        functions.any? ? self : FilteredQuery.new(query: query, filter: filter).simplify
      end

      def to_search
        {
          function_score: super
        }
      end

    end
  end
end

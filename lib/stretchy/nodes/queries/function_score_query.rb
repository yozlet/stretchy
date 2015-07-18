require 'stretchy/nodes/queries/base'
require 'stretchy/nodes/boosts/base'

module Stretchy
  module Nodes
    module Queries
      class FunctionScoreQuery < Base

        SCORE_MODES = %w(multiply sum avg first max min)
        BOOST_MODES = %w(multiply replace sum avg max min)

        attribute :functions, Array[Boosts::Base]
        attribute :query,     Base
        attribute :filter,    Filters::Base
        attribute :score_mode
        attribute :boost_mode
        attribute :min_score
        attribute :max_boost
        attribute :boost

        validations do
          rule :functions,  type: {classes: Boosts::Base, array: true}
          rule :query,      type: {classes: Base}
          rule :filter,     type: {classes: Filters::Base}
          rule :score_mode, inclusion: {in: SCORE_MODES}
          rule :boost_mode, inclusion: {in: BOOST_MODES}
          rule :min_score,  type: {classes: Numeric}
          rule :max_boost,  type: {classes: Numeric}
          rule :boost,      type: {classes: Numeric}
        end

        def to_search
          json = {}
          attributes.each do |field, value|
            json[field] = value if value
          end
          json[:functions]  = @functions.map(&:to_search)
          if @query
            json[:query]    = @query.to_search
          elsif @filter
            json[:filter]   = @filter.to_search
          else
            json[:query]    = Stretchy::Queries::MatchAllQuery.new.to_search
          end

          { function_score: json }
        end
      end
    end
  end
end

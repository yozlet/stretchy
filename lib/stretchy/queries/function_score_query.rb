require 'stretchy/queries/base'
require 'stretchy/boosts/base'

module Stretchy
  module Queries
    class FunctionScoreQuery < Base

      SCORE_MODES = %w(multiply sum avg first max min)
      BOOST_MODES = %w(multiply replace sum avg max min)

      contract functions: {type: Stretchy::Boosts::Base, array: true},
                   query: {type: Base},
                  filter: {type: Stretchy::Filters::Base},
              score_mode: {type: String, in: SCORE_MODES},
              boost_mode: {type: String, in: BOOST_MODES},
               min_score: {type: Numeric},
               max_boost: {type: Numeric},
                   boost: {type: Numeric}

      def initialize(options = {})
        @functions  = Array(options[:functions])
        @query      = options[:query]
        @filter     = options[:filter]
        
        self.class.attributes.map do |field|
          instance_variable_set("@#{field}", options[field])
        end
        validate!
        validate_query_or_filter
      end

      def self.attributes
        [:boost, :max_boost, :score_mode, :boost_mode, :min_score]
      end

      def validate_query_or_filter
        if @query && @filter
          raise Stretchy::Errors::ContractError.new "Cannot have both query and filter -- combine using a FilteredQuery"
        end
      end

      def to_search
        json = {}
        json[:functions]  = @functions.map(&:to_search)
        if @query
          json[:query]    = @query.to_search
        elsif @filter
          json[:filter]   = @filter.to_search
        else
          json[:query]    = Stretchy::Queries::MatchAllQuery.new.to_search
        end

        self.class.attributes.reduce(json) do |body, field|
          ivar = instance_variable_get("@#{field}")
          body[field] = ivar if ivar
          body
        end

        { function_score: json }
      end
    end
  end
end

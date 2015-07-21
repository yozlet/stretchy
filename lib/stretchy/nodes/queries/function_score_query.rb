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
          rule :score_mode, inclusion: {in: SCORE_MODES}
          rule :boost_mode, inclusion: {in: BOOST_MODES}
          rule :query,      type: Base
          rule :filter,     type: Filters::Base
          rule :min_score,  type: Numeric
          rule :max_boost,  type: Numeric
          rule :boost,      type: Numeric
        end

        def to_search
          json              = json_attributes
          json[:functions]  = functions.map(&:to_search)
          if query
            json[:query]    = query.to_search
            json.delete(:filter)
          elsif filter
            json[:filter]   = filter.to_search
            json.delete(:query)
          end

          { function_score: json }
        end

        def add_query(node, options = {})
          if filter_only?
            filtered_query.add_query(node, options)
          elsif query.respond_to?(:add_query)
            @query = query.add_query(node)
          else
            @query = node
          end
          self
        end

        def add_filter(node, options = {})
          if query.respond_to?(:add_filter)
            @query = query.add_filter(node)
          elsif filter.respond_to?(:add_filter)
            @filter = filter.add_filter(node)
          elsif
            @filter = node
          end
          self
        end

        def add_boost(node, options = {})
          functions << node
        end

        private

          def filter_only?
            filter && !query
          end

          def filtered_query
            @query  = FilteredQuery.new(query: node, filter: filter)
            @filter = nil
            query
          end

      end
    end
  end
end

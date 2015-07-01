module Stretchy
  module AST
    class MatchQuery < Base

      attribute :field, String
      attribute :query, Array
      attribute :operator, String
      attribute :zero_terms_query, String
      attribute :cutoff_frequency, Float
      attribute :analyzer, String
      attribute :type, String
      attribute :slop, Integer
      attribute :minimum_should_match, Integer
      attribute :max_expansions, Integer

      validations do
        rule :operator, inclusion: { in: ['and', 'or'] }
        rule :type, inclusion: { in: ['phrase', 'phrase_prefix'] }
        rule :query, type: { classes: String, array: true }
      end

      def compile
        query_params = json_attributes.reject { |k, _| [:field, :query].include?(k) }
        query_params.merge!(query: query.join(' '))

        {
          match: {
            field => query_params
          }
        }
      end
    end
  end
end

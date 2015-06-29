module Stretchy
  module Builders
    class QueryBuilder

      extend Forwardable

      delegate [:any?, :count, :length] => :to_enum

      attr_reader :queries, :matches, :query_opts

      def initialize
        @queries    = []
        @matches    = Hash.new { [] }
        @query_opts = Hash.new { {} }
      end

      def add_query(query)
        @queries << query
      end

      def add_matches(field, new_matches, options = {})
        @matches[field] += Array(new_matches)
        opts = {}
        [:operator, :slop, :minimum_should_match, :min, :type].each do |opt|
          opts[opt] = options[opt] if options[opt]
        end
        @query_opts[field] = opts
      end

      def to_enum
        queries + matches.values
      end

      def to_queries
        queries + matches.map do |field, phrases|
          opts = query_opts[field].merge(
            field: field,
            string: phrases.flatten.join(' ')
          )
          Queries::MatchQuery.new(opts)
        end
      end

    end
  end
end

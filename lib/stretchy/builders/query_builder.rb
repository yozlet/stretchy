module Stretchy
  module Builders
    class QueryBuilder

      extend Forwardable

      delegate [:any?, :count, :length] => :matches

      attr_reader :matches, :operators

      def initialize
        @matches    = Hash.new { [] }
        @operators  = Hash.new { 'and' }
      end

      def add_matches(field, new_matches, options)
        @matches[field] += Array(new_matches).map(&:to_s).map(&:strip).reject(&:empty?)
        if options[:operator]
          @operators[field] = options[:operator]
        elsif options[:or]
          @operators[field] = 'or'
        end
      end

      def to_query
        matches.map do |field, matches_for_field|
          Queries::MatchQuery.new(
            field:    field,
            string:   matches_for_field.join(' '),
            operator: operators[field]
          )
        end
      end

    end
  end
end
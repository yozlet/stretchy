require 'stretchy/clauses/boost_clause'

module Stretchy
  module Clauses
    class BoostMatchClause < BoostClause

      def initialize(base, opts_or_string = {}, options = {})
        super(base)
        if opts_or_string.is_a?(Hash)
          @inverse = opts_or_string.delete(:inverse) || options.delete(:inverse)
          match_function(opts_or_string.merge(options))
        else
          @inverse = options.delete(:inverse)
          match_function(options.merge('_all' => opts_or_string))
        end
      end

      def not(opts_or_string = {}, options = {})
        self.class.new(self, opts_or_string, options.merge(inverse: !inverse?))
      end

      private

        def match_function(options = {})
          weight = options.delete(:weight)
          clause = MatchClause.tmp(options)
          boost  = clause.to_boost(weight)
          @boost_builder.functions << boost if boost
        end

    end
  end
end
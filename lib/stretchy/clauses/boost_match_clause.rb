module Stretchy
  module Clauses
    class BoostMatchClause < BoostClause

      def initialize(base, opts_or_str = {}, options = {})
        super(base)
        if opts_or_str.is_a?(Hash)
          @inverse = opts_or_str.delete(:inverse) || options.delete(:inverse)
          match_function(options.merge(opts_or_str))
        else
          @inverse = options.delete(:inverse)
          match_function(options.merge('_all' => opts_or_str))
        end
      end

      def not(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(inverse: !inverse?))
      end

      private

        def match_function(options = {})
          weight = options.delete(:weight)
          clause = MatchClause.tmp(options)
          @boost_builder.functions << {
            filter: Stretchy::Filters::QueryFilter.new(clause.to_query),
            weight: weight
          }
        end

    end
  end
end
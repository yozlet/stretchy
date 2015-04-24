module Stretchy
  module Clauses
    class BoostClause < Base

      def initialize(base, options = {})
        super(base)
        @inverse = options.delete(:inverse)
      end

      def match(options = {})
        BoostMatchClause.new(self, options)
      end

      def where(options = {})
        BoostWhereClause.new(self, options)
      end

      def all(num)
        @boost_builder.overall_boost = num
        self
      end

      def max(num)
        @boost_builder.max_boost = num
        self
      end

      def score_mode(mode)
        @boost_builder.score_mode = mode
        self
      end

      def boost_mode(mode)
        @boost_builder.boost_mode = mode
        self
      end

      def not(options = {})
        self.class.new(self, options.merge(inverse: !inverse?))
      end

    end
  end
end
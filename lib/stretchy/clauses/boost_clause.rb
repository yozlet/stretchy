module Stretchy
  module Clauses
    class BoostClause < Base

      extend Forwardable

      delegate [:geo, :range] => :where

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

      def near(options = {})
        options.each do |field, params|
          if params.is_a?(Time)
            
          elsif params.is_a?(Numeric)

          elsif params.is_a?(Hash) && params([:lat] || params[:latitude])

          end
        end
      end

      def random(*args)
        @boost_builder.functions << Stretchy::Boosts::RandomBoost.new(*args)
        self
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
        inst = self.class.new(self, options.merge(inverse: !inverse?))
        inst
      end

    end
  end
end
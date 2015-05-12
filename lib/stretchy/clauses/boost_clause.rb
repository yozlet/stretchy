require 'stretchy/clauses/base'

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
      alias :fulltext :match

      def where(options = {})
        BoostWhereClause.new(self, options)
      end
      alias :filter :where

      def near(options = {})
        if options[:lat] || options[:latitude]  ||
           options[:lng] || options[:longitude] || options[:lon]

          options[:origin] = Stretchy::Types::GeoPoint.new(options)
        end
        @boost_builder.functions << Stretchy::Boosts::FieldDecayBoost.new(options)
        self
      end
      alias :geo :near

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
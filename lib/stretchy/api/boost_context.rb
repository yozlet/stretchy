require 'stretchy/api/context'

module Stretchy
  module API
    class BoostContext < Context

      def raw(params = {}, options = {})
        current.add_boost(
          Nodes::Boosts::ParamsBoost.new(params),
          options
        )
        base
      end

      def field(params = {}, options = {})
        current.add_boost(
          Nodes::Boosts::FieldDecayBoost.new(params),
          options
        )
        base
      end

      def value(params = {}, options = {})
        current.add_boost(
          Nodes::Boosts::FieldValueBoost.new(params),
          options
        )
        base
      end

      def random(params = {}, options = {})
        current.add_boost(
          Nodes::Boosts::RandomBoost.new(params),
          options
        )
        base
      end

    end
  end
end

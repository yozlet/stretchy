require 'stretchy/utils/contract'

module Stretchy
  module Boosts
    class Base

      include Stretchy::Utils::Contract

      DEFAULT_WEIGHT    = 1.2
      DEFAULT_DECAY_FN  = :gauss

      def initialize
        raise "Override this in subclass"
      end

      def to_search
        raise "Override this in subclass"
      end

    end
  end
end
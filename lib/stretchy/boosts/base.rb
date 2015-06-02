require 'stretchy/utils/validation'

module Stretchy
  module Boosts
    class Base

      include Stretchy::Utils::Validation

      DEFAULT_WEIGHT    = 1.2

      def initialize
        raise "Override this in subclass"
      end

      def to_search
        raise "Override this in subclass"
      end

    end
  end
end
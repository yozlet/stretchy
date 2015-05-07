require 'stretchy/utils/contract'

module Stretchy
  module Types
    class Base

      include Stretchy::Utils::Contract

      def initialize
        raise "Override this in subclass"
      end

      def to_search
        raise "Override this in subclass"
      end

    end
  end
end
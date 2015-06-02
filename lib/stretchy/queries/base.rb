require 'stretchy/utils/validation'

module Stretchy
  module Queries
    class Base

      include Stretchy::Utils::Validation

      def initialize
        raise "Override this in subclass"
      end

      def to_search
        raise "Override this in subclass"
      end

    end
  end
end

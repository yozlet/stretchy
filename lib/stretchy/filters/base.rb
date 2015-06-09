require 'stretchy/utils/validation'

module Stretchy
  module Filters
    class Base

      extend Forwardable

      include Utils::Validation

      def initialize
        raise "Override this in subclass"
      end

      def to_search
        raise "Override this in subclass"
      end

    end
  end
end

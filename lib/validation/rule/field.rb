module Validation
  module Rule
    class Field

      def error_key
        :field
      end

      def valid_value?(value)
        valid = true
        valid = false unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(Numeric)
        valid = false if value.to_s.empty?
        valid
      end

      def params
        {}
      end

    end
  end
end
module Validation
  module Rule
    class Required

      def error_key
        :required
      end

      def valid_value?(value)
        case value
        when nil
          false
        when String, Array, Hash
          !value.empty?
        else
          true
        end
      end

      def params
        {}
      end

    end
  end
end
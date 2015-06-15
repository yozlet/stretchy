module Validation
  module Rule
    class Required < StretchyRule

      def error_key
        :required
      end

      def valid_value?(value)
        !is_empty?(value)
      end
    end
  end
end
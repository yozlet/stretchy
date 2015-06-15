module Validation
  module Rule
    class MinShouldMatch < StretchyRule

      FORMAT_REGEX = /^-?\d+([<>]-?\d+)?%?$/

      def error_key
        :field
      end

      def valid_value?(value)
        return true if empty_ok?(value)
        value.to_s =~ FORMAT_REGEX
      end

    end
  end
end
module Validation
  module Rule
    class Latitude < StretchyRule

      def error_key
        :latitude
      end

      def valid_value?(value)
        valid = true
        value = Float(value) rescue nil
        valid = false unless value && value.to_f <= 90 && value.to_f >= -90
        valid
      end
    end
  end
end
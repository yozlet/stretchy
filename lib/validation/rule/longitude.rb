module Validation
  module Rule
    class Longitude < StretchyRule

      def error_key
        :longitude
      end

      def valid_value?(value)
        valid = true
        value = Float(value) rescue nil
        valid = false unless value && value <= 180 && value >= -180
        valid
      end
    end
  end
end
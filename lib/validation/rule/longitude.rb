module Validation
  module Rule
    class Longitude

      def error_key
        :longitude
      end

      def valid_value?(value)
        valid = true
        value = Float(value) rescue nil
        valid = false unless value && value <= 180 && value >= -180
        valid
      end

      def params
        {}
      end

    end
  end
end
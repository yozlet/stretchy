module Validation
  module Rule
    class Distance
      DISTANCE_FORMAT = /^(\d+)(km|mi)$/

      def error_key
        :distance_value
      end

      def valid_value?(value)
        !!(value.to_s =~ DISTANCE_FORMAT)
      end

      def params
        {}
      end

    end
  end
end
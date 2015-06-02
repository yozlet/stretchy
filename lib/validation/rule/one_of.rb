module Validation
  module Rule
    class OneOf

      def initialize(params)
        @params = params
      end

      def error_key
        :one_of
      end

      def valid_value?(value)
        
      end

      def params
        @params
      end
    end
  end
end
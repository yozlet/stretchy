module Validation
  module Rule
    class Inclusion

      def initialize(params = {})
        @params = params
      end

      def error_key
        :inclusion
      end

      def valid_value?(value)
        return true if value.nil? && !params[:required]
        within.any? do |allowed_value|
          if value.respond_to?(:eql?)
            value.eql?(allowed_value)
          else
            value == allowed_value
          end
        end
      end

      def within
        @params[:in] || @params[:within]
      end

      def params
        @params
      end
    end
  end
end
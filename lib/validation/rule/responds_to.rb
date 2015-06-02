module Validation
  module Rule
    class RespondsTo

      def initialize(params)
        @params = params
      end

      def error_key
        :responds_to
      end

      def valid_value?(value)
        value.respond_to?(params[:method])
      end

      def params
        @params
      end

    end
  end
end
module Validation
  module Rule
    class StretchyRule

      def initialize(params = {})
        @params = params
      end

      def error_key
        raise "Override in subclass"
      end

      def valid_value?(value)
        raise "Override in subclass"
      end

      def empty_ok?(value)
        !required? && is_empty?(value)
      end

      def invalid_empty?(value)
        required? && is_empty?(value)
      end

      def is_empty?(value)
        Stretchy::Utils.is_empty?(value)
      end

      def required?
        !!(params.is_a?(Hash) && params[:required])
      end

      def params
        @params
      end
    end
  end
end

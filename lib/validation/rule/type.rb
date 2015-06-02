module Validation
  module Rule
    class Type

      def initialize(params = {})
        @params = params
      end

      def error_key
        :type_rule
      end

      def valid_value?(value)
        return true if value.nil? && !params[:required]
        
        valid = true
        if params[:array]
          valid = false unless value.all? {|v| validate_type(v) }
        else
          valid = false unless validate_type(value)
        end
        valid
      end

      def validate_type(value)
        valid = true
        case params[:classes]
        when Array
          valid = false unless params[:classes].any? {|type| value.is_a?(type) }
        else
          valid = false unless value.is_a?(params[:classes])
        end
        valid
      end

      def params
        @params
      end
    end
  end
end
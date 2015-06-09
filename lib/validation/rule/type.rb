module Validation
  module Rule
    class Type < StretchyRule

      def initialize(params = {})
        if params.is_a?(Hash)
          @params = params
          @params[:classes] = Array(params[:classes])
        else
          @params = { classes: Array(params) }
        end
      end

      def error_key
        :type_rule
      end

      def valid_value?(value)
        return true if value.nil? && !params[:required]
        if params[:array]
          value.all? {|v| valid_type?(v) }
        else
          valid_type?(value)
        end
      end

      def valid_type?(value)
        params[:classes].any? {|type| value.is_a?(type) }
      end
    end
  end
end
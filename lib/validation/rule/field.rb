module Validation
  module Rule
    class Field < StretchyRule

      def error_key
        :field
      end

      def valid_value?(value)
        if params[:array]
          value.all? {|v| valid_class?(v) && !is_empty?(v) }
        else
          valid_class?(value) && !is_empty?(value)
        end
      end

      def valid_class?(value)
        [String, Symbol, Numeric].any?{|c| value.is_a?(c) }
      end
    end
  end
end
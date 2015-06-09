module Validation
  module Rule
    class Inclusion < StretchyRule

      def error_key
        :inclusion
      end

      def valid_value?(value)
        return true if empty_ok?(value)
        within.any? do |allowed_value|
          if value.respond_to?(:eql?)
            value.eql?(allowed_value)
          else
            value == allowed_value
          end
        end
      end

      def within
        params[:in] || params[:within]
      end
    end
  end
end
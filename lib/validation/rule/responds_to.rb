module Validation
  module Rule
    class RespondsTo < StretchyRule

      def error_key
        :responds_to
      end

      def valid_value?(value)
        value.respond_to?(params[:method])
      end
    end
  end
end
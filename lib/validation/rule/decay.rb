module Validation
  module Rule
    class Decay < StretchyRule
      DECAY_FUNCTIONS = [:gauss, :linear, :exp]

      def error_key
        :decay_function
      end

      def valid_value?(value)
        DECAY_FUNCTIONS.any?{|f| f == value || f.to_s == value }
      end
    end
  end
end
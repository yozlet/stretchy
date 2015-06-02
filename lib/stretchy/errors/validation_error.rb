module Stretchy
  module Errors
    class ValidationError < StandardError

      def initialize(errors)
        @errors = errors
      end

      def message
        @errors.map do |key, err|
          "Attribute #{key} violated rule #{err[:rule]}"
        end.join("\n")
      end

    end
  end
end

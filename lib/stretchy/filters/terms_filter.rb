module Stretchy
  module Filters
    class TermsFilter

      def initialize(field:, values:)
        @field = field
        @values = Array(values)
      end

      def to_search
        {
          terms: {
            @field => @values
          }
        }
      end
    end
  end
end

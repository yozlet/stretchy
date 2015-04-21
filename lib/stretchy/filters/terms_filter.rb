module Stretchy
  module Filters
    class TermsFilter < Base

      contract field: {type: :field},
              values: {type: Array}

      def initialize(field:, values:)
        @field = field
        @values = Array(values)
        validate!
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

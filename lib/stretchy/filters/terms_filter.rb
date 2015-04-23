module Stretchy
  module Filters
    class TermsFilter < Base

      contract field: {type: :field},
              values: {type: Array}

      def initialize(options = {})
        @fields = options
        validate!
      end

      def to_search
        {
          terms: @fields
        }
      end
    end
  end
end

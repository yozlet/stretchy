require 'stretchy/filters/base'

module Stretchy
  module Filters
    class TermsFilter < Base

      contract field: {type: :field, required: true},
               terms: {type: [Numeric, Time, String, Symbol], array: true,  required: true}

      def initialize(field, terms)
        @field = field
        @terms = Array(terms)
        validate!
      end

      def to_search
        {
          terms: {
            @field => @terms
          }
        }
      end
    end
  end
end

module Stretchy
  module Queries
    class MatchQuery < Base

      OPERATORS = ['and', 'or']

      contract field: {type: :field},
            operator: {type: String, in: OPERATORS},
              string: {type: String}

      def initialize(string, field: '_all', operator: 'and')
        @field    = field
        @operator = operator
        @string   = string
        validate!
      end

      def to_search
        {
          match: {
            @field => {
              query: @string,
              operator: @operator
            }
          }
        }
      end

    end
  end
end

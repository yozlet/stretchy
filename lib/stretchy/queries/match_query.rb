module Stretchy
  module Queries
    class MatchQuery < Base

      OPERATORS = ['and', 'or']

      contract field: {type: :field},
            operator: {type: String, in: OPERATORS},
              string: {type: String}

      def initialize(options = {})
        case options
        when String
          @field    = '_all'
          @string   = options
          @operator = 'and'
        when Hash
          @field    = options[:field]    || '_all'
          @string   = options[:string]
          @operator = options[:operator] || 'and'
        end
        validate!
      end

      def to_search
        {
          match: {
            @field => {
              query:    @string,
              operator: @operator
            }
          }
        }
      end

    end
  end
end

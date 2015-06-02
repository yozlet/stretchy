require 'stretchy/queries/base'

module Stretchy
  module Queries
    class MatchQuery < Base

      OPERATORS = ['and', 'or']

      attribute :field
      attribute :string
      attribute :operator

      validations do
        rule :field, :field
        rule :operator, inclusion: {in: OPERATORS}
        rule :string, type: {classes: String}
        rule :string, :required
      end

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

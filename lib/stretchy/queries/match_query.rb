module Stretchy
  module Queries
    class MatchQuery < Base

      OPERATORS = ['and', 'or']

      contract fields: {type: :field},
            operator: {type: String, in: OPERATORS},
              string: {type: String}

      def initialize(fields)
        @fields = fields
      end

      def to_search
        json = {match: {}}
        @fields.each do |field|
          json[:match][field[:name]] = {
            query: field[:query],
            operator: field[:operator]
          }
        end
        json
      end

    end
  end
end

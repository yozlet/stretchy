require 'stretchy/api/context'

module Stretchy
  module API
    class QueryContext < Context

      def raw(params = {}, options = {})
        current.add_query(
          Nodes::Queries::ParamsQuery.new(params: params),
          options
        )
        base
      end

      def match(params = {}, options = {})
        if params.is_a?(String)
          current.add_query(
            Nodes::Queries::MatchQuery.new(field: '_all', string: params),
            options
          )
        elsif params.is_a?(Hash)
          params.each do |field, val|
            current.add_query(
              Nodes::Queries::MatchQuery.new(field: field, string: params),
              options
            )
          end
        end
        base
      end

      def more_like(params = {}, options = {})
        current.add_query(
          Nodes::Queries::MoreLikeThisQuery.new(params),
          options
        )
        base
      end

    end
  end
end

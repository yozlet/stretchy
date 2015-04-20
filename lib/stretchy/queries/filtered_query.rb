module Stretchy
  module Queries
    class FilteredQuery < Base

      contract query: {type: Base},
              filter: {type: Stretchy::Filters::Base}

      def initialize(query: nil, filter:)
        @query  = query
        @filter = filter
        validate!
      end

      def to_search
        json = {}
        json[:query]  = @query.to_search  if @query
        json[:filter] = @filter.to_search if @filter
        { filtered: json }
      end
    end
  end
end

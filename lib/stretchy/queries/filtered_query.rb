require 'stretchy/queries/base'
require 'stretchy/filters/base'

module Stretchy
  module Queries
    class FilteredQuery < Base

      contract query: {type: Base},
              filter: {type: Stretchy::Filters::Base}

      def initialize(options = {})
        @query  = options[:query]
        @filter = options[:filter]
        validate!
        require_one(query: @query, filter: @filter)
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

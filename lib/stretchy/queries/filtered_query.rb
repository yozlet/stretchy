require 'stretchy/queries/base'
require 'stretchy/filters/base'

module Stretchy
  module Queries
    class FilteredQuery < Base

      attribute :query,  Base
      attribute :filter, Filters::Base

      validations do
        rule :query, type: {classes: Base}
        rule :filter, type: {classes: Filters::Base}
      end

      def initialize(options = {})
        @query  = options[:query]
        @filter = options[:filter]
        require_one! :query, :filter
        validate!
      end

      def to_search
        json = {}
        json[:query]  = @query.to_search  if query
        json[:filter] = @filter.to_search if filter
        { filtered: json }
      end
    end
  end
end

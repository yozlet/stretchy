require 'stretchy/nodes/queries/base'
require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Queries
      class FilteredQuery < Base

        attribute :query,  Base
        attribute :filter, Filters::Base

        validations do
          rule :query, type:  Base
          rule :filter, type: Filters::Base
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
end

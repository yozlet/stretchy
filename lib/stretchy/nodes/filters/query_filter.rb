require 'stretchy/nodes/filters/base'
require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Filters
      class QueryFilter < Base

        attribute :query, Queries::Base

        validations do
          rule :query, type: {classes: Queries::Base}
        end

        def to_search
          {
            query: @query.to_search
          }
        end
      end
    end
  end
end

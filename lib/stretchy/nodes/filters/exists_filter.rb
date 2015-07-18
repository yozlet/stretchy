require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters
      # CAUTION: this will match empty strings
      # see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html
      class ExistsFilter < Base

        attribute :field

        validations do
          rule :field, field: { required: true }
        end

        def to_search
          {
            exists: {
              field: @field
            }
          }
        end
      end
    end
  end
end

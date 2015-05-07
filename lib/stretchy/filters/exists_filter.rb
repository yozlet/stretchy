require 'stretchy/filters/base'

module Stretchy
  module Filters
    class ExistsFilter < Base

      contract field: {type: :field, required: true}

      # CAUTION: this will match empty strings
      # see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html
      def initialize(field)
        @field = field
        validate!
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

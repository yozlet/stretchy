require 'stretchy/ast/base'

module Stretchy
  module AST
    # CAUTION: this will match empty strings
    # see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html
    class ExistsFilter < Base

      attribute :field

      validations do
        rule :field, field: { required: true }
      end

      def to_search
        {
          exists: super
        }
      end
    end
  end
end

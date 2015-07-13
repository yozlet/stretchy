require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class TermsFilter < Base

      attribute :field
      attribute :terms

      validations do
        rule :field, field: { required: true }
        rule :terms, type: {classes: [Numeric, Time, String, Symbol, TrueClass, FalseClass], array: true}
        rule :terms, :not_empty
      end

      def node_type
        :filter
      end

      def initialize(field, terms)
        @field = field
        @terms = Array(terms)
        validate!
      end

      def to_search
        {
          terms: {
            @field => @terms
          }
        }
      end

      def add_query(node, options = {})
        replace_node(self, FilteredQuery.new(
          query: node,
          filter: self
        ))
      end
    end
  end
end

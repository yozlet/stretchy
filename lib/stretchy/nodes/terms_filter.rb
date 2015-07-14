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

      def add_filter(node, options = {})
        if node.is_a?(self.class) && node.field == field
          @terms += Array(node.terms)
          @terms =  @terms.compact.uniq
          self
        else
          replace_node(self, BoolFilter.new(
            must: NodeCollection.new(nodes: [self, node])
          ))
        end
      end

      def combine_with(node, options = {})
        if node.is_a?(self.class) && node.field == field
          @terms += node.terms
        end
      end
    end
  end
end

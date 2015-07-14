require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class NodeCollection < Base

      include Enumerable
      delegate [:each] => :nodes

      attribute :nodes, Array[Base], default: []

      def add(node, options = {})
        combine_nodes(node, options) || @nodes << node
      end

      def combine_nodes(node, options = {})
        nodes.find do |current_node|
          current_node.combine_with(node)
        end
      end

      def convert_to_bool(options = {})
        replace_self(self, options[:klass].new(
          options[:context] => self
        ))
      end

      def to_search
        nodes.map(&:to_search)
      end

    end
  end
end

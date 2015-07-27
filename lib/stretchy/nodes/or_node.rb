module Stretchy
  module Nodes
    class OrNode

      extend Forwardable
      delegate [:json, :context] => :node

      attr_reader :context, :nodes

      def initialize(context = {}, nodes = [])
        @context = context
        @nodes = []

        nodes.each {|node| store_node(node) }
      end

      def node
        pp [:or_dot_node, nodes]
        if context[:query]
          Node.new(context, dis_max: {
            queries: nodes.map(&:json)
          })
        else
          Node.new(context, or: nodes.map(&:json))
        end
      end

      def or(or_nodes)
        self.class.new(context, nodes + Array(or_nodes))
      end

      def and(and_nodes)
        BoolNode.new(context, [self] + Array(and_nodes))
      end

      private

        def store_node(node)
          if node.context[:query] && context[:filter]
            @nodes << Node.new(context, query: node.json)
          elsif node.context[:filter] && context[:query]
            @nodes << Node.new(context, filtered: { filter: node.json })
          else
            @nodes << node
          end
        end

    end
  end
end

module Stretchy
  module Nodes
    class BoolNode

      extend Forwardable
      delegate [:json, :context] => :node

      attr_reader :must, :must_not, :should

      def initialize(context = {}, nodes = [])
        @context  = context
        @must     = []
        @must_not = []
        @should   = []

        nodes.each {|node| store_node(node) }
      end

      def node
        @node ||= if must_not.any? || should.any? || must.count > 1
          bool_node
        else
          must.first
        end
      end

      def nodes
        must + must_not + should
      end

      def or(or_nodes)
        OrNode.new(context, [self] + Array.new(or_nodes)
      end

      def and(and_nodes)
        self.class.new(context, nodes + and_nodes)
      end

      private

        def bool_node
          node_json = {}
          node_json[:must]      = must.map(&:json)      if must.any?
          node_json[:must_not]  = must_not.map(&:json)  if must_not.any?
          node_json[:should]    = should_json           if should.any?

          Node.new({}, bool: node_json)
        end

        def should_json
          node_json = self.class.new({}, should).json
          node_json = [node_json] unless node_json.is_a?(Array)
          node_json
        end

        def store_node(node)
          if node.context[:should]
            @should << Node.new(
              node.context.merge(should: false),
              node.json
            )
          elsif node.context[:must_not]
            @must_not << node
          else
            @must << node
          end
        end

    end
  end
end

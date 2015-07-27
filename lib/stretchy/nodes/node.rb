module Stretchy
  module Nodes
    class Node

      attr_reader :json, :context

      def initialize(context, json)
        @json     = json.dup
        @context  = context.dup
      end

      def merge(node)
        BoolNode.new(context, [self, node])
      end

      def or(node)
        OrNode.new(context, [self, node])
      end

      def and(node)
        BoolNode.new(context, [self, node])
      end

    end
  end
end

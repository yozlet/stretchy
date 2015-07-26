module Stretchy
  class LogicTree

    extend Forwardable
    delegate [:json, :context] => :node

    attr_reader :must, :must_not, :should

    def initialize(nodes = [])
      @must     = []
      @must_not = []
      @should   = []

      nodes.each {|node| store_node(node) }
    end

    def node
      @node ||= if must_not.any? || should.any?
        bool_node
      elsif must.count > 1
        Node.new({}, bool: {must: must.map(&:json)})
      else
        must.first
      end
    end

    def nodes
      must + must_not + should
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
        node_json = self.class.new(should).json
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

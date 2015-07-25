module Stretchy
  class QueryTree

    extend Forwardable

    delegate [:kind, :json, :context] => :node

    attr_reader :queries, :filters, :boosts

    def initialize(nodes = [])
      @queries = []
      @filters = []
      @boosts  = []

      nodes.each {|node| store_node(node) }
    end

    def node
      @node ||= if filters.any?
        filtered_query
      else
        LogicTree.new(:bool_query, queries)
      end
    end

    private

      def store_node(node)
        if node.context[:boost]
          @boosts << node
        elsif node.context[:filter] && node.context[:query]
          @filters << Node.new(node.context, query: node.json)
        elsif node.context[:filter]
          @filters << node
        elsif node.context[:query]
          @queries << node
        end
      end

      def filtered_query
        filtered_json = {}
        if queries.any?
          filtered_json[:query] = LogicTree.new(:bool_query, queries).json
        end

        if filters.any?
          filtered_json[:filter] = LogicTree.new(:bool_filter, filters).json
        end

        Node.new({}, filtered: filtered_json)
      end

  end
end

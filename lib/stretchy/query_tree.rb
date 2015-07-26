module Stretchy
  class QueryTree

    extend Forwardable
    delegate [:json, :context] => :node

    attr_reader :queries, :filters, :boosts

    def initialize(nodes = [])
      @queries = []
      @filters = []
      @boosts  = []

      nodes.each {|node| store_node(node) }
    end

    def node
      @node ||= if boosts.any?
        function_score_query
      elsif filters.any?
        filtered_query
      else
        LogicTree.new(queries)
      end
    end

    def nodes
      queries + filters + boosts
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
          filtered_json[:query] = LogicTree.new(queries).json
        end

        if filters.any?
          filtered_json[:filter] = LogicTree.new(filters).json
        end

        Node.new({}, filtered: filtered_json)
      end

      def function_score_query
        function_json = {}
        function_json[:functions] = @boosts.map(&:json)

        if filters.any? && queries.empty?
          function_json[:filter] = LogicTree.new(filters).json
        elsif queries.any? && filters.empty?
          function_json[:query] = LogicTree.new(queries).json
        else
          function_json[:query] = filtered_query.json
        end

        Node.new({}, function_score: function_json)
      end

  end
end

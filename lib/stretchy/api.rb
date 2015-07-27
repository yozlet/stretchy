module Stretchy
  class API

    extend Forwardable

    attr_reader :nodes, :context

    def initialize(params = {})
      @nodes     = Array(params[:nodes])
      @context   = params[:context] || clear_context!
    end

    def node
      @node ||= Nodes::QueryNode.new(context, nodes).node
      @node
    end

    def where(params = {})
      @context[:filter] = true unless @context[:query]
      return self unless params.any?

      if context[:or]
        replace_or(params)
      else
        self.class.new nodes: nodes + Factory.where_nodes(context, params)
      end
    end

    def fulltext(params = {}, meta = {})
      @context[:query] = true
      return self unless params.any?

      if context[:or]
        replace_or(params)
      else
        self.class.new nodes: nodes + Factory.match_nodes(context, params, meta)
      end
    end

    def not(params = {})
      context_method(params, :must_not)
    end

    def should(params = {})
      context_method(params, :should)
    end

    def boost(params = {})
      context_method(params, :boost)
    end

    def query(params = {})
      abstract_method(params, :query)
    end

    def filter(params = {})
      abstract_method(params, :filter)
    end

    def and(params = {})
      bool_nodes = [nodes.last] + if context[:query]
        Factory.match_nodes(context, params)
      else
        Factory.where_nodes(context, params)
      end
      new_nodes = nodes[0..-1] + [Nodes::BoolNode.new(context, bool_nodes)]
      self.class.new nodes: new_nodes
    end

    def or(params = {})
      if params.any?
        or_nodes = if or_context[:query]
          Factory.match_nodes(or_context, params)
        else
          Factory.where_nodes(or_context, params)
        end
        replace_or(or_nodes)
      else
        context[:or] = true
        self
      end
    end

    def json
      {
        query: node.json
      }
    end

    private
      def clear_context!
        @context = {
          query:    false,
          filter:   false,
          must_not: false,
          should:   false,
          or:       false,
          and:      false
        }
      end

      def clear_context?
        context.none?{|k,v| v}
      end

      # method shifts context
      #
      # if there are any params, it will apply them in the
      # new context, then clear, then return self
      #
      # otherwise, just shifts to new context and returns
      # self
      def context_method(params, method = :context)
        @context[method] = true
        if params.any?
          if context[:query]
            fulltext(params)
          elsif context[:filter]
            where(params)
          else
            raise "call .query or .filter before #{kind}"
          end
        else
          self
        end
      end

      # adds raw json to your query, putting it in the right
      # place via context
      #
      # allows unsupported queries & filters
      def abstract_method(params, method = :context)
        @context[method] = true
        if params.any?
          self.class.new nodes: nodes + [Node.new(context, params)]
        end
        self
      end

      def or_context
        clear_context? ? nodes.last.context : context
      end

      def replace_or(or_nodes)
        new_nodes = nodes[0..-2] + [Nodes::OrNode.new(or_context, or_nodes)]
        self.class.new nodes: new_nodes
      end

  end
end

require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class Root < Base

      attribute :query,   Base
      attribute :from,    Integer
      attribute :size,    Integer
      attribute :explain, Axiom::Types::Boolean

      def add_query(node, options = {})
        if query
          query.add_query(node, options)
        else
          @query = node
        end
      end

    end
  end
end

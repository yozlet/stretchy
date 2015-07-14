require 'stretchy/nodes/base'
require 'stretchy/nodes/node_collection'

module Stretchy
  module Nodes
    class BoolFilter < Base

      attribute :must,      NodeCollection, default: NodeCollection.new
      attribute :must_not,  NodeCollection, default: NodeCollection.new
      attribute :should,    NodeCollection, default: NodeCollection.new

      def to_search
        json = {}
        json[:must]     = must.to_search      if must.any?
        json[:must_not] = must_not.to_search  if must_not.any?
        json[:should]   = should.to_search    if should.any?
        { bool: json }
      end

      def add_filter(node, options = {})
        if options[:context] == :should_not
          should.convert_to_bool(klass: self.class, context: :must_not)
        else
          send(options[:context]).add_node(node)
        end
        self
      end
    end
  end
end

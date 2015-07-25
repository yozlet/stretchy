module Stretchy
  class Collector

    extend Forwardable

    delegate [:node] => :tree
    delegate [:kind, :json, :context] => :node

    attr_accessor :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end

    def spawn
      self.class.new(@nodes.dup)
    end

    def tree
      @tree ||= QueryTree.new(nodes)
    end
  end
end

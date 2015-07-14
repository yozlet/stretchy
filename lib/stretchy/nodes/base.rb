require 'stretchy/utils/validation'

module Stretchy
  module Nodes
    class Base

      include Utils::Validation

      attribute :parent

      validations do
        rule :parent, type: Base
      end

      # general classification of the node's type
      # determines which add_ method is called
      # for this node
      def node_type
        :base
      end

      def add(node, options = {})
        method_name = to_method(node)
        if respond_to?(method_name)
          send(method_name, node, options)
        elsif parent && parent.respond_to?(method_name)
          parent.send(method_name, node, options)
        else
          raise "Cannot add #{node.class.name} to #{self.class.name}"
        end
      end

      def replace_node(node, new_node)
        field, val = self.attributes.find do |field, val|
          val == node
        end

        if field
          self[field] = new_node
          new_node.parent = self
          new_node
        elsif parent.respond_to?(:replace_node)
          parent.send(:replace_node, node, new_node)
          new_node.parent = self
          new_node
        end
      end

      # override in subclasses to combine this node
      # with a similar node (ie, combining multiple)
      # queries and filters on the same field
      #
      # return nil if nodes cannot be combined
      def combine_with(node, options = {})
        nil
      end

      def to_search(options = {})
        options[:reject] = Array(options[:reject]) + [:parent]

        json = json_attributes(options).map do |name, obj|
          obj.respond_to?(:to_search) ? [name, obj.to_search] : [name, obj]
        end

        Hash[json]
      end

      def after_initialize(options = {})
        self.attributes.each do |field, val|
          val.parent = self if val.respond_to?(:parent=)
        end
      end

      private

        def to_method(node)
          "add_#{node.node_type}".to_sym
        end

    end
  end
end

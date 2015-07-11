module Stretchy
  module Lispy
    class Tree

      def self.flatten(tree)
        key, params, root = tree
        # [:terms, {a: [:b]}]
        case key
        when :where
          {
            where: [params]
          }
        when :match
          {
            matches: [params] # [{a: :b}, {c: :d}, {a: :f}]
          }
        when :and
          if root
            merge(flatten(params), flatten(root))
          else
            flatten(params)
          end
        when :not
          {
            not: flatten(params)
          }
        end
      end

      def self.merge(a, b)
        result = a.dup
        b.each do |k, v|
          if k == :not
            result[:not] = merge(result[:not] || {}, v)
          else
            result[k] ||= []
            result[k] = result[k] + v
          end
        end
        result
      end

      def initialize(root, options = {})
        @root = root
      end

      def where(params = {}, options = {})
        self.class.new [:and, [:where, params], @root]
      end

      def match(params = {}, options = {})
        self.class.new [:and, [:match, params], @root]
      end

      def not_match(params = {})
        self.class.new [:and, [:not, [:match, params]], @root]
      end

      def not_where(params = {}, options = {})
        self.class.new [:and, [:not, [:where, params]], @root]
      end

      def should_match(params = {})
        self.class.new [:and, [:should, [:match, params]], @root]
      end

      def should_where(params = {}, options = {})
        self.class.new [:and, [:should, [:where, params]], @root]
      end

      def should_not_where(params = {}, options = {})
        self.class.new [:and, [:not, [:should, [:where, params]]], @root]
      end

      def should_not_match(params = {}, options = {})
        self.class.new [:and, [:not, [:should, [:match, params]]], @root]
      end

      def boost_where
        [:boost, [:terms, params]]
      end

      def flatten
        self.class.flatten(@root)
      end

      def to_search
        # method_to_tranform_flattend_tree_to_elastic_json(flatten)
      end

    end
  end
end

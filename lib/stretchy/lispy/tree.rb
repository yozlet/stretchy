module Stretchy
  module Lispy
    class Tree

      def initialize(root = [], options = {})
        @root = root
      end

      def where(params = {}, options = {})
        self.class.new [:and, [:terms, params]]
      end

      def match(params = {}, options = {})
        self.class.new [:and, [:match, params]]
      end

      def not_match(params = {})
        self.class.new [:and, [:not, [:match, params]], @root]
      end

      def not_where(params = {}, options = {})
        self.class.new [:and, [:not, [:terms, params]], @root]
      end

      def should_match(params = {})
        self.class.new [:and, [:should, [:match, params]], @root]
      end

      def should_where(params = {}, options = {})
        self.class.new [:and, [:should, [:terms, params]], @root]
      end

      def should_not_where(params = {}, options = {})
        self.class.new [:and, [:not, [:should, [:terms, params]]], @root]
      end

      def should_not_match(params = {}, options = {})
        self.class.new [:and, [:not, [:should, [:match, params]]], @root]
      end

      def boost_where
        [:boost, [:terms, params]]
      end

      def to_search
        compile(@root)
      end

      private

        def compile(tree)
          key, params, root = tree

          # [:terms, {a: [:b]}]
          case key
          when :terms
            {
              filters: Array(params)
            }
          when :match
            {
              matches: Array(params) # [{a: :b}, {c: :d}, {a: :f}]
            }
          when :and
            compile(params).recursive_merge(root)
          when :not
            inner_key, inner_tree = params
            {
              not: compile(inner_tree)
            }
          when :should
            {
              should: compile(inner_tree)
            }
          when :should_not

          end

          {
            filters: [
              {
                a: :b
              },
              {
                c: :d
              }
            ],
            matches: {
              {d: :e}
            },

            # deal with this in compile_2 method
            not: {
              matches: {

                },
                fitlers: {

                }
            }

            terms_should: {
              matches: [
                {a: :b}
              ]
            }
          }
        end

    end
  end
end

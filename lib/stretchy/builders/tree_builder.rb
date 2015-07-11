module Stretchy
  module Builders
    class TreeBuilder

      module Parser

        def parse(tree)
          key, first, second = tree
          parse_args = second ? [first, second] : [first]
          raise "Invalid key: #{key}" unless respond_to?("parse_#{key}")
          send("parse_#{key}", *parse_args)
        end

        def parse_root(tree, options)
          Utils.deep_merge parse(tree), options
        end

        def parse_boost(tree, root)
          Utils.deep_merge({functions: parse(tree)}, parse(root))
        end

        def parse_and(first, second)
          Utils.deep_merge parse(first), parse(second)
        end

        def parse_query(tree)
          {queries: parse(tree)}
        end

        def parse_filter(tree)
          {filters: parse(tree)}
        end

        def parse_not(tree)
          { must_not: parse(tree) }
        end

        def parse_terms(params)
          params.map do |field, terms|
            {
              terms: {
                field => Array(terms)
              }
            }
          end
        end

        # [:match, params, options]
        def parse_match(params, options)
          params.map do |field, query|
            match_json = {query: query}.merge(options)
            {
              match: {
                field => match_json
              }
            }
          end
        end

      end

      extend Parser

      module Compiler

        def flatten(dict)
          Hash[dict.map do |key, val|
            if respond_to?("flatten_#{key}")
              [key, send("flatten_#{key}", val)]
            else
              [key, val]
            end
          end]
        end

        def flatten_filters(filters)
          flattened = extract_filter_types(filters)
          combined  = combine_filter_types(flattened)
          combined
        end


        # reduce [
        #   { terms: {a: [:b]}},
        #   { terms: {a: [:c]}},
        #   { range: {f: {min: 1}}},
        #   { range: {f: {min: 2}}}
        # ]
        # to {
        #   terms: [
        #     {a: [:b]},
        #     {a: [:c]}
        #   ],
        #   range: [
        #     {f: {min: 1}},
        #     {f: {min: 2}}
        #   ]
        # }
        #
        def extract_filter_types(filters)
          flattened = Hash.new { [] }
          filters.inject(flattened) do |memo, filter|
            filter_type, values = filter.to_a.first
            memo[filter_type] += [values]
            memo
          end
        end

        # call flatten_terms on
        #   terms: [
        #     {a: [:b]},
        #     {a: [:c]}
        #   ]
        #
        # and flatten_range on
        #   range: [
        #     {f: {min: 1}},
        #     {f: {min: 2}}
        #   ]
        #
        def combine_filter_types(values)
          values.inject([]) do |memo, item|
            filter_type, sub_filters = item
            if respond_to?("flatten_#{filter_type}")
              memo += Array(send("flatten_#{filter_type}", sub_filters))
            else
              memo += Array(sub_filters)
            end
            memo
          end
        end

        # change [
        #   {a: [:b]},
        #   {a: [:c]},
        #   {d: [:e]}
        # ]
        #
        # to [
        #   { terms: {a: [:b, :c]}},
        #   { terms: {d: [:e]}}
        # ]
        #
        def flatten_terms(term_filters)
          flattened = term_filters.inject({}) do |memo, item|
            Utils.deep_merge memo, item
          end

          flattened.map do |field, val|
            {
              terms: { field => val }
            }
          end
        end

      end

      extend Compiler
    end
  end
end

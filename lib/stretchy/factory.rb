module Stretchy
  module Factory

    module_function

    def where_nodes(context, params = {})
      meta = params.delete(:meta) || {}
      params.map do |field, values|
        case values
        when Range
          Node.new(context, field => meta.merge(
            gte: values.min,
            lte: values.max
          ))
        when Array
          Node.new(context, terms: meta.merge(field => values))
        else
          Node.new(context, term: meta.merge(field => values))
        end
      end
    end

    def match_nodes(context, params = {}, meta = {})
      meta = params.delete(:meta) || meta if params.is_a?(Hash)
      if params.is_a?(String)
        [Node.new(context, match: meta.merge(_all: params))]
      else
        params.map do |field, values|
          case values
          when Array
            Node.new(
              context.merge(should: true),
              terms: meta.merge(field => values.join(' '))
            )
          else
            Node.new(context, match: meta.merge(field => values))
          end
        end
      end
    end

    def dis_max(context, node, params = {})
      meta = params.delete(:meta) || {}
      Node.new(context, dis_max: meta.merge(queries: [node.json, Factory.match_nodes(context, params, meta).json]))
    end

  end
end

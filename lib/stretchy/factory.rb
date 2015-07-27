module Stretchy
  module Factory

    module_function

    def where_nodes(context, params = {})
      meta = params.delete(:meta) || {}
      params.map do |field, values|
        case values
        when Range
          Nodes::Node.new(context, field => meta.merge(
            gte: values.min,
            lte: values.max
          ))
        when Array
          Nodes::Node.new(context, terms: meta.merge(field => values))
        else
          Nodes::Node.new(context, term: meta.merge(field => values))
        end
      end
    end

    def match_nodes(context, params = {}, meta = {})
      meta = params.delete(:meta) || meta if params.is_a?(Hash)
      if params.is_a?(String)
        [Nodes::Node.new(context, match: meta.merge(_all: params))]
      else
        params.map do |field, values|
          case values
          when Array
            Nodes::Node.new(
              context.merge(should: true),
              terms: {field => meta.merge(query: values.join(' '))}
            )
          else
            Nodes::Node.new(context, match: {field => meta.merge(query: values)})
          end
        end
      end
    end

  end
end

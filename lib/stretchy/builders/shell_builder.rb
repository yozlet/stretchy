module Stretchy
  module Builders
    class ShellBuilder

      DEFAULT_LIMIT   = 30
      DEFAULT_OFFSET  = 0

      attr_accessor :index, :type, :limit, :offset, :explain,
                    :match_builder, :where_builder, :boost_builder, 
                    :aggregate_builder, :fields

      def initialize(options = {})
        @index              = options[:index] || Stretchy.index_name
        @match_builder      = Stretchy::Builders::MatchBuilder.new
        @where_builder      = Stretchy::Builders::WhereBuilder.new
        @boost_builder      = Stretchy::Builders::BoostBuilder.new
        @aggregate_builder  = {}
        @limit              = options[:limit]  || DEFAULT_LIMIT
        @offset             = options[:offset] || DEFAULT_OFFSET
        @fields             = options[:fields]
        @type               = options[:type]
      end

      def page
        (offset.to_f / limit).ceil + 1
      end
      alias :current_page :page

      # 
      # Compiles the internal representation of your filters,
      # full-text queries, and boosts into the JSON to be 
      # passed to Elastic. If you want to know exactly what
      # your query generated, you can call this method.
      # 
      # @return [Hash] the query hash to be compiled to json 
      #   and sent to Elastic
      def to_search
        _to_search = if where_builder.any?
          Stretchy::Queries::FilteredQuery.new(
            query:  match_builder.to_query,
            filter: where_builder.to_filter
          )
        else
          match_builder.to_query
        end

        _to_search = boost_builder.to_search(_to_search) if boost_builder.any?
        _to_search.to_search
      end

    end
  end
end
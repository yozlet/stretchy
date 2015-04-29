module Stretchy
  module Clauses
    class Base

      extend Forwardable

      DEFAULT_LIMIT   = 30
      DEFAULT_OFFSET  = 0

      attr_accessor :match_builder, :where_builder, :boost_builder, 
                    :aggregate_builder, :inverse, :type, :index_name

      alias :inverse? :inverse

      delegate [:response, :results, :ids, :hits, :took, :shards, :total, :max_score] => :query_results

      def initialize(base_or_opts = nil, options = {})
        if base_or_opts && !base_or_opts.is_a?(Hash)
          base                = base_or_opts
          @index_name         = base.index_name
          @type               = base.type
          @match_builder      = base.match_builder
          @where_builder      = base.where_builder
          @boost_builder      = base.boost_builder
          @aggregate_builder  = base.aggregate_builder
          @inverse            = options[:inverse] || base.inverse
          @limit              = base.get_limit
          @offset             = base.get_offset
        else
          options = Hash(base_or_opts).merge(options)
          @index_name         = options[:index] || Stretchy.index_name
          @type               = options[:type]
          @match_builder      = Stretchy::Builders::MatchBuilder.new
          @where_builder      = Stretchy::Builders::WhereBuilder.new
          @boost_builder      = Stretchy::Builders::BoostBuilder.new
          @aggregate_builder  = nil
          @inverse            = options[:inverse]
          @limit              = DEFAULT_LIMIT
          @offset             = DEFAULT_OFFSET
        end
      end

      def limit(num)
        @limit = num
        self
      end

      def get_limit
        @limit
      end

      def offset(num)
        @offset = num
        self
      end

      def get_offset
        @offset
      end

      def match(options = {})
        MatchClause.new(self, options)
      end

      def where(options = {})
        WhereClause.new(self, options)
      end

      def boost(options = {})
        BoostClause.new(self, options)
      end

      def to_search
        return @to_search if @to_search
        
        @to_search = if @where_builder.any?
          Stretchy::Queries::FilteredQuery.new(
            query:  @match_builder.build,
            filter: @where_builder.build
          )
        else
          @match_builder.build
        end

        @to_search = @boost_builder.build(@to_search) if @boost_builder.any?
        @to_search = @to_search.to_search
      end

      def query_results
        @query_results ||= Stretchy::Results::Base.new(to_search.merge(from: @limit, size: @offset), type: @type)
      end

    end
  end
end
module Stretchy
  module Clauses
    # A Clause is the basic unit of Stretchy's chainable query syntax.
    # Think of it as a state machine, with transitions between states
    # being handled by methods that return another Clause. When you
    # call the `where` method, it stores the params passed as an 
    # internal representation, to be compiled down to the Elastic query
    # syntax, and returns a WhereClause. The WhereClause reflects the
    # current state of the query, and gives you access to methods like
    # `range` and `geo` to add more specific filters. It inherits
    # other methods from the Base class, allowing other transitions.
    #
    # Attributes are copied when a new Clause is instanciated, so
    # the underlying storage is maintained throughout the chain.
    class Base

      extend Forwardable

      DEFAULT_LIMIT   = 30
      DEFAULT_OFFSET  = 0

      attr_accessor :match_builder, :where_builder, :boost_builder, 
                    :aggregate_builder, :inverse, :type, :index_name

      delegate [:request, :response, :results, :ids, :hits, 
                :took, :shards, :total, :max_score] => :query_results
      delegate [:range, :geo] => :where

      #
      # Generates a chainable query. The only required option for the
      # first initialization is `:type` , which specifies what type
      # to query on your index.
      # 
      # @overload initialize(base_or_opts, options)
      #   @param [Base] another clause to copy attributes from
      #   @param [Hash] options to set on the new state
      # 
      # @overload initialize(base_or_opts)
      #   @option base_or_opts [String] :index        The Elastic index to query
      #   @option base_or_opts [String] :type         The Lucene type to query on
      #   @option base_or_opts [true, false] :inverse Whether we are in a `not` context
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

      # 
      # Sets how many results to return, similar to
      # ActiveRecord's limit method.
      # 
      # @param num [Integer] How many results to return
      # 
      # @return [self]
      def limit(num)
        @limit = num
        self
      end

      # 
      # Accessor for `@limit`
      # 
      # @return [Integer] Value of `@limit`
      def get_limit
        @limit
      end

      # 
      # Sets the offset to start returning results at.
      # Corresponds to Elastic's "from" parameter
      # 
      # @param num [Integer] Offset for query
      # 
      # @return [self]
      def offset(num)
        @offset = num
        self
      end

      # 
      # Accessor for `@offset`
      # 
      # @return [Integer] Offset for query
      def get_offset
        @offset
      end

      # 
      # Used for fulltext searching. Works similarly
      # to {#where} .
      # 
      # @param options = {} [Hash] Options to be passed to 
      #   the MatchClause
      # 
      # @return [MatchClause] query state with fulltext matches
      # @see MatchClause#initialize
      def match(options = {})
        MatchClause.new(self, options)
      end
      alias :fulltext :match

      # 
      # Used for filtering results. Works similarly to
      # ActiveRecord's `where` method.
      # 
      # @param options = {} [Hash] Options to be passed to
      #   the {WhereClause}
      # 
      # @return [WhereClause] query state with filters
      # @see  WhereClause#initialize
      def where(options = {})
        WhereClause.new(self, options)
      end
      alias :filter :where

      # 
      # Used for boosting the relevance score of
      # search results. Options passed here correspond
      # to `where`-style filters which boost a document
      # if matched.
      # 
      # @param options = {} [type] [description]
      # 
      # @return [type] [description]
      def boost(options = {})
        BoostClause.new(self, options)
      end

      # 
      # Inverts the current context - the next method
      # called, such as {#where} or {#match} will generate
      # a filter specifying the document **does not**
      # match the specified filter.
      # 
      # @overload not(string)
      #   @param [String] A string that must not be anywhere
      #                   in the document
      # 
      # @overload not(opts_or_string)
      #   @param [Hash] Options to be passed to an inverted {WhereClause}
      # 
      # @return [Base] A {WhereClause}, or a {MatchClause} if only a string 
      #   is given (ie, doing a full-text search across the whole document)
      def not(opts_or_string = {}, opts = {})
        if opts_or_string.is_a?(Hash)
          WhereClause.new(self, opts_or_string.merge(inverse: true))
        else
          MatchClause.new(self, opts_or_string, opts.merge(inverse: true))
        end
      end

      # 
      # Adds filters in the `should` context. Operates just like
      # {#where}, but these filters only serve to add to the 
      # relevance score of the returned documents, rather than
      # being required to match.
      # 
      # @overload  should(opts_or_string)
      #   @param [String] A string to match via full-text search 
      #     anywhere in the document.
      # 
      # @overload should(opts_or_string)
      #   @param [Hash] Options to generate filters.
      # 
      # @return [WhereClause] current query state with should clauses applied
      def should(opts_or_string = {}, opts = {})
        if opts_or_string.is_a?(Hash)
          WhereClause.new(self, opts_or_string.merge(should: true))
        else
          MatchClause.new(self, opts_or_string, opts.merge(should: true))
        end
      end

      # 
      # Accessor for `@inverse`
      # 
      # @return [true, false] If current context is inverse
      def inverse?
        !!@inverse
      end

      # 
      # Compiles the internal representation of your filters,
      # full-text queries, and boosts into the JSON to be 
      # passed to Elastic. If you want to know exactly what
      # your query generated, you can call this method.
      # 
      # @return [Hash] the query hash to be compiled to json 
      #   and sent to Elastic
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

      # 
      # The Results object for this query, which handles
      # sending the search request and providing convienent
      # accessors for the response.
      # 
      # @return [Results::Base] The results returned from Elastic
      def query_results
        @query_results ||= Stretchy::Results::Base.new(self)
      end

    end
  end
end

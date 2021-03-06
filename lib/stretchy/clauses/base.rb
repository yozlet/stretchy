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

      attr_reader :base

      delegate [:request, :response, :results, :ids, :hits, :query,
                :took, :shards, :total, :max_score, :total_pages] => :query_results
      delegate [:to_search] => :base
      delegate [:where, :range, :geo, :terms, :not, :filter] => :build_where
      delegate [:match, :fulltext, :more_like, :query] => :build_match

      #
      # Generates a chainable query. The only required option for the
      # first initialization is `:type` , which specifies what type
      # to query on your index.
      #
      # @overload initialize(base_or_opts, params)
      #   @param base [Base] another clause to copy attributes from
      #   @param params [Hash] params to set on the new state
      #
      # @overload initialize(base_or_opts)
      #   @option base_or_opts [String] :index        The Elastic index to query
      #   @option base_or_opts [String] :type         The Lucene type to query on
      #   @option base_or_opts [true, false] :inverse Whether we are in a `not` context
      def initialize(base = nil, params = {})
        if base.is_a?(Builders::ShellBuilder)
          @base = base
        elsif base.nil?
          @base = Builders::ShellBuilder.new
          @base.index ||= params[:index] || Stretchy.index_name
          @base.type    = params[:type]  if params[:type]
        else
          @base = Builders::ShellBuilder.new(base)
        end
      end

      #
      # Exits any state the query is in (boost, inverse, should, etc)
      # and returns to the root query state. You can use this before
      # calling `.where` or other overridden methods to ensure they
      # are being processed from the base state.
      #
      # If you have to call this method, please file an issue.
      # End-of-chain methods (such as `.boost.where.not()`) should
      # always return to the root state, and state is not
      # something you should have to think about.
      #
      # @return [Base] Continue the query chain from the root state
      #
      def root
        Base.new(base)
      end

      #
      # Sets how many results to return, similar to
      # ActiveRecord's limit method.
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html Elastic Docs - Request Body Search
      #
      # @param num [Integer] How many results to return
      #
      # @return [self]
      def limit(num)
        base.limit = num
        self
      end

      #
      # Accessor for `@limit`
      #
      # @return [Integer] Value of `@limit`
      def get_limit
        base.limit
      end
      alias :limit_value :get_limit

      #
      # Sets the offset to start returning results at.
      # Corresponds to Elastic's "from" parameter
      #
      # @param num [Integer] Offset for query
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html Elastic Docs - Request Body Search
      #
      # @return [self]
      def offset(num)
        base.offset = num
        self
      end
      alias :per_page :offset

      #
      # Accessor for `@offset`
      #
      # @return [Integer] Offset for query
      def get_offset
        base.offset
      end

      #
      # Allows pagination via Kaminari-like accessor
      # @param num [Integer] Page number. Natural numbers only, **this is not zero-indexed**
      # @option per_page [Integer] :per_page (DEFAULT_LIMIT) Number of results per page
      #
      # @return [self] Allows continuing the query chain
      def page(num, params = {})
        base.limit  = params[:limit] || params[:per_page] || get_limit
        base.offset = [(num - 1), 0].max.ceil * get_limit
        self
      end

      #
      # Accessor for current page
      #
      # @return [Integer] (offset / limit).ceil
      def get_page
        base.page
      end
      alias :current_page :get_page

      #
      # Select fields for Elasticsearch to return
      #
      # By default, Stretchy will return the entire _source
      # for each document. If you call `.fields` with no
      # arguments or an empty array, Stretchy will pass
      # an empty array and only the "_type" and "_id"
      # fields will be returned.
      #
      # @see  https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-fields.html Elastic Docs - Fields
      #
      # @param new_fields [Array] Fields elasticsearch should return
      #
      # @return [self] Allows continuing the query chain
      def fields(*args)
        base.fields ||= []
        base.fields += args.flatten if args.any?
        self
      end

      #
      # Accessor for fields Elasticsearch will return
      #
      # @return [Array] List of fields in the current query
      def get_fields
        base.fields
      end

      #
      # Tells the search to explain the scoring
      # mechanism for each document.
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-explain.html Elastic Docs - Request Body Search (explain)
      #
      # @return [self] Allows continuing the query chain
      def explain
        base.explain = true
        self
      end

      def get_explain
        !!base.explain
      end

      #
      # Filter for documents that do not match the specified fields and values
      #
      # @overload not(params)
      #   @param [String] A string that must not be matched anywhere in the document
      # @overload not(params)
      #   @param [Hash] A hash of fields and strings or terms that must not be matched in those fields
      #
      # @return [MatchClause, WhereClause] inverted query state with match filters applied
      #
      # @see {MatchClause#not}
      # @see {WhereClause#not}
      #
      def not(params = {}, options = {})
        if params.is_a?(String)
          build_match.not(params, options)
        else
          build_where.not(params, options)
        end
      end

      #
      # Used for boosting the relevance score of
      # search results. `match` and `where` clauses
      # added after `boost` will be applied as
      # boosting functions instead of filters
      #
      # @example Boost documents that match a filter
      #   query.boost.where('post.user_id' => current_user.id)
      #
      # @example Boost documents that match fulltext search
      #   query.boost.match('user search terms')
      #
      # @return [BoostClause] query in boost context
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html Elastic Docs - Function Score Query
      def boost
        BoostClause.new(base)
      end

      #
      # Adds filters in the `should` context. Operates just like
      # {#where}, but these filters only serve to add to the
      # relevance score of the returned documents, rather than
      # being required to match.
      #
      # @overload  should(params)
      #   @param [String] A string to match via full-text search
      #     anywhere in the document.
      #
      # @overload should(params)
      #   @param [Hash] Options to generate filters.
      #
      # @return [WhereClause] current query state with should clauses applied
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html Elastic Docs - Bool Query
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-filter.html Elastic Docs - Bool Filter
      def should(params = {}, options = {})
        if params.is_a?(Hash)
          WhereClause.new(base).should(params, options)
        else
          MatchClause.new(base).should(params, options)
        end
      end

      #
      # Allows adding raw aggregation JSON to your
      # query
      # @param params = {} [Hash] JSON to aggregate on
      #
      # @return [self] Allows continuing the query chain
      def aggregations(params = {})
        base.aggregate_builder = base.aggregate_builder.merge(params)
        self
      end
      alias :aggs :aggregations

      def get_aggregations
        base.aggregate_builder
      end
      alias :get_aggs :get_aggregations

      #
      # Accessor for `@inverse`
      #
      # @return [true, false] If current context is inverse
      def inverse?
        !!@inverse
      end

      #
      # The Results object for this query, which handles
      # sending the search request and providing convienent
      # accessors for the response.
      #
      # @return [Results::Base] The results returned from Elastic
      def query_results
        @query_results ||= Stretchy::Results::Base.new(base)
      end

      protected

        def build_match
          MatchClause.new(base)
        end

        def build_where
          WhereClause.new(base)
        end

        def hashify_params(params)
          params.is_a?(String) ? { '_all' => params } : params
        end

        def merge_state(options = {})
          options[:should]  = true if options[:should].nil?  && should?
          options[:inverse] = true if options[:inverse].nil? && inverse?
          options
        end

    end
  end
end

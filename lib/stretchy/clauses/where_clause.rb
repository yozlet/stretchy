require 'stretchy/clauses/base'

module Stretchy
  module Clauses
      #
      # A Where clause inherits the same state as any clause,
      # but has a few possible states to transition to. You
      # can call {#range} and {#geo} to add their respective
      # filters, or you can transition to the inverted state
      # via {#not}, or the `should` state via {#should}
      #
      # ### STATES:
      # * **inverted:** any filters added in this state will be
      #   inverted, ie the document must **NOT** match said
      #   filters.
      # * **should:** any filters added in this state will be
      #   applied to a `should` block. Documents which do
      #   not match these filters will be returned, but
      #   documents which do match will have a higher
      #   relevance score.
      #
      # @author [atevans]
      #
    class WhereClause < Base

      #
      # Add term-style filters to the query. This is similar to ActiveRecord's `where`
      # method. Also exits any should or inverse state. To add terms to those states,
      # chain the `.should` or `.not` methods after this one.
      #
      # @param params = {} [Hash] filters to be applied to the new state
      #
      # @example Apply ActiveRecord-like filters
      #   query.where(
      #     string_field: "string",
      #     must_not_exist: nil,
      #     in_range: 27..33,
      #     included_in: [47, 23, 86]
      #   )
      #
      # @example Apply should filters
      #   query.where.should(
      #     string_field: "string"
      #   )
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-filter.html Elastic Docs - Terms Filter
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html Elastic Docs - Exists Filter
      #
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-filter.html Elastic Docs - Range Filter
      #
      def where(params = {}, options = {})
        @inverse = false
        @should  = false
        add_params(params, options)
        self
      end

      #
      # Add arbitrary json as a filter in the appropriate context.
      # This can be used to add filters that are not currently supported
      # by Stretchy to be used in the final query.
      #
      # @param params = {} [Hash] Filter to be applied to the new state
      # @option  options [true, false] :inverse (nil) Ignore query state and add to the `not` filters
      # @option  options [true, false] :should (nil) Ignore query state and add to the `should` filters
      def filter(params, options = {})
        base.where_builder.add_filter(
          Filters::ParamsFilter.new(params),
          merge_state(options)
        )
        self
      end

      #
      # Accessor for `@should`
      #
      # @return [true, false] `@should`
      def should?
        !!@should
      end

      #
      # Add a range filter to the current context. While
      # you can pass a `Range` object to {#where}, this
      # allows you to specify an open-ended range, such
      # as only specifying the minimum or maximum value.
      #
      # @param field [String, Symbol] The field to filter with this range
      # @param options = {} [Hash] Options for the range
      # @option options [Numeric] :min (nil) Minimum. Ranges are _inclusive_ by default
      # @option options [Numeric] :max (nil) Maximum. Ranges are _inclusive_ by default
      # @option options [true, false] :exclusive (nil) Overrides default and makes the range exclusive -
      #   equivalent to passing both `:exclusive_min` and `:exclusive_max`
      # @option options [true, false] :exclusive_min (nil) Overrides default and makes the minimum exclusive
      # @option options [true, false] :exclusive_max (nil) Overrides default and makes the maximum exclusive
      #
      # @return [self] query state with range filter applied
      #
      # @example Adding a range filter
      #   query.where.range(:my_range_field,
      #     min: 33,
      #     exclusive: true
      #   )
      def range(field, options = {})
        options = merge_state(options)
        base.where_builder.add_range(field, options)
        self
      end

      #
      # Adds a geo distance filter to the current context.
      # Documents must have a `geo_point` field that is within
      # the specified distance of the passed parameters.
      #
      # @param field [String, Symbol] The field this filter will be applied to.
      # @param options = {} [Hash] Options for the geo distance filter
      # @option options [String] :distance (nil) The maximum distance from the specified origin.
      #   Use an Elastic distance format such as `'21mi'` or `'37km'`
      # @option options [Float] :lat (nil) The latitude of the origin point. Can also be specified as `:latitude`
      # @option options [Float] :lng (nil) The longitude of the origin point.
      #   Can also be specified as `:lon` or `:longitude`
      #
      # @return [self] query state with geo distance filter applied
      #
      # @example Searching by distance from a point
      #   query.where.geo(:coords,
      #     distance: '27km',
      #     lat: 33.3,
      #     lng: 29.2
      #   )
      def geo(field, options = {})
        distance = options[:distance]
        options = merge_state(options)
        base.where_builder.add_geo(field, distance, options)
        self
      end

      #
      # Used for passing strings or symbols in a `.where`
      # method, and using the un-analyzed Terms filter instead
      # of an analyzed and parsed Match Query.
      #
      # This would be useful if you have a set of specific
      # strings a field could be in, such as:
      # `role: ['admin_user', 'company_manager']`
      # and you want to query for those exact strings without
      # the usual downcase / punctuation removal analysis.
      #
      # **CAUTION:** The keys indexed by elastic may be analyzed -
      # downcased, punctuation removed, etc. Using a terms filter
      # in this case _will not work_ . Hence the default of using
      # a match query for strings and symbols instead.
      #
      # @param options = {} [Hash] Options to be passed to the
      #   {WhereClause}
      #
      # @return [WhereClause] query state with filters applied
      #
      # @example Querying for exact terms
      #   query.where.terms(
      #     status_field: 'working_fine_today',
      #     number: 27,
      #     date: Date.today
      #   )
      #
      # @example Not matching exact terms
      #   query.where.not.terms(
      #     email: 'my.email@company.com'
      #   )
      #
      # @example Should match exact terms
      #   query.should.terms(
      #     hacker_alias: '!!ic3y.h0t~~!'
      #   )
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-filter.html Elasticsearch Terms Filter
      def terms(params = {}, options = {})
        options[:exact] = true
        add_params(params, options)
        self
      end
      alias :exact :terms

      #
      # Switches current state to inverted. Options passed
      # here are equivalent to those passed to {#initialize},
      # except documents *must not* match these filters.
      #
      # Can be chained with {#should} to produce inverted should queries
      #
      # @param params = {} [Hash] params to filter on
      #
      # @return [WhereClause] inverted query state with not filters applied.
      #
      # @example Inverting filters
      #   query.where.not(
      #     must_exist: nil,
      #     not_matching: "this string",
      #     not_in: [45, 67, 99],
      #     not_in_range: 89..23
      #   )
      #
      # @example Inverted should filters
      #   query.should.not(
      #     match_field: [:these, "params"]
      #   )
      def not(params = {}, options = {})
        @inverse = true
        add_params(params, options)
        self
      end

      #
      # Switches the current state to `should`. Options passed
      # here are equivalent to those passed to {#initialize},
      # except documents which do not match are still returned
      # with a lower score than documents which do match.
      #
      # Can be chained with {#not} to produce inverted should queries
      #
      # **CAUTION:** Documents that don't match at least one `should`
      # clause will not be returned.
      #
      # @param params = {} [Hash] params to filter on
      #
      # @return [WhereClause] should query state with should filters applied
      #
      # @example Specifying should params
      #   query.should(
      #     field: [99, 27]
      #   )
      #
      # @example Inverted should params
      #   query.should.not(
      #     exists_field: nil
      #   )
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/1.4/query-dsl-bool-query.html Elasticsearch Bool Query docs (bool filter just references this)
      def should(params = {}, options = {})
        @inverse = false
        @should  = true
        add_params(params, options)
        self
      end

      #
      # Converts the current context into a boost to
      # be passed into a {FunctionScoreQuery}.
      #
      # @param weight = nil [Numeric] A weight for the {FunctionScoreQuery}
      #
      # @return [Boosts::FilterBoost] A boost including all the current filters
      def to_boost(weight = nil)
        weight ||= Stretchy::Boosts::FilterBoost::DEFAULT_WEIGHT

        if base.match_builder.any? && base.where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              Stretchy::Queries::FilteredQuery.new(
                query:  base.match_builder.to_query,
                filter: base.where_builder.to_filter
              )
            ),
            weight: weight
          )

        elsif base.match_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              base.match_builder.to_query
            ),
            weight: weight
          )

        elsif base.where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: base.where_builder.to_filter,
            weight: weight
          )
        end
      end

      private

        def add_params(params = {}, options = {})
          params.each do |field, param|
            # if it is an array, process each param
            # separately - ensures string & symbols
            # always go into .match_builder

            if param.is_a?(Array)
              param.each{|p| add_param(field, p, options) }
            else
              add_param(field, param, options)
            end
          end
        end

        def add_param(field, param, options = {})
          opts = {}
          opts[:inverse] = true if inverse?
          opts[:should]  = true if should?

          if (param.is_a?(String) || param.is_a?(Symbol)) && !options[:exact]
            base.match_builder.add_matches(field, param, opts)
          else
            base.where_builder.add_param(field, param, opts)
          end
        end

    end
  end
end

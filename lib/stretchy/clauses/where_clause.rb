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
      # Creates a temporary context by initializing a new Base object.
      # Used primarily in {BoostWhereClause}
      # 
      # @param options = {} [Hash] Options to filter on
      # 
      # @return [WhereClause] A clause outside the main query context
      def self.tmp(options = {})
        self.new(Base.new, options)
      end

      # 
      # Options passed to the initializer will be interpreted as filters
      # to be added to the query. This is similar to ActiveRecord's `where`
      # method.
      # 
      # @param base [Base] Used to intialize the new state from the previous clause
      # @param options = {} [Hash] filters to be applied to the new state
      # @option  options [true, false] :inverted (nil) Whether the new state is inverted
      # @option  options [true, false] :should (nil) Whether the new state is should
      # 
      # @example Apply ActiveRecord-like filters
      #   query.where(
      #     string_field: "string",
      #     must_not_exist: nil,
      #     in_range: 27..33,
      #     included_in: [47, 23, 86]
      #   )
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-filter.html Elastic Docs - Terms Filter
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html Elastic Docs - Exists Filter
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-filter.html Elastic Docs - Range Filter
      # 
      def initialize(base, options = {})
        super(base)
        @inverse = options.delete(:inverse)
        @should  = options.delete(:should)
        add_params(options)
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
        get_storage(:ranges)[field] = Stretchy::Types::Range.new(options)
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
        get_storage(:geos)[field] = {
          distance:  options[:distance],
          geo_point: Stretchy::Types::GeoPoint.new(options)
        }
        self
      end

      # 
      # Switches current state to inverted. Options passed 
      # here are equivalent to those passed to {#initialize},
      # except documents *must not* match these filters.
      # 
      # Can be chained with {#should} to produce inverted should queries
      # 
      # @param options = {} [Hash] Options to filter on
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
      #     match_field: [:these, "options"]
      #   )
      def not(options = {})
        self.class.new(self, options.merge(inverse: true, should: should?))
      end

      # 
      # Switches the current state to `should`. Options passed
      # here are equivalent to those passed to {#initialize},
      # except documents which do not match are still returned
      # with a lower score than documents which do match.
      # 
      # Can be chained with {#not} to produce inverted should queries
      # 
      # @param options = {} [Hash] Options to filter on
      # 
      # @return [WhereClause] should query state with should filters applied
      # 
      # @example Specifying should options
      #   query.should(
      #     field: [99, 27]
      #   )
      # 
      # @example Inverted should options
      #   query.should.not(
      #     exists_field: nil
      #   ) 
      def should(options = {})
        self.class.new(self, options.merge(should: true))
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
        
        if @match_builder.any? && @where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              Stretchy::Queries::FilteredQuery.new(
                query:  @match_builder.build,
                filter: @where_builder.build
              )
            ),
            weight: weight
          )
        
        elsif @match_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              @match_builder.build
            ),
            weight: weight
          )

        elsif @where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: @where_builder.build,
            weight: weight
          )
        end
      end

      private

        def get_storage(builder_field, is_inverse = nil)
          is_inverse = inverse? if is_inverse.nil?
          field = builder_field.to_s
          if inverse? || is_inverse
            if should?
              field = "shouldnot#{field}"
            else
              field = "anti#{field}"
            end
          else
            field = "should#{field}" if should?
          end
          
          if field =~ /match/
            @match_builder.send(field)
          else
            @where_builder.send(field)
          end
        end
        
        def add_params(options = {})
          options.each do |field, param|
            # if it is an array, process each param
            # separately - ensures string & symbols
            # always go into .match_builder
            
            if param.is_a?(Array)
              param.each{|p| add_param(field, p) }
            else
              add_param(field, param)
            end
          end
        end

        def add_param(field, param)
          case param
          when nil
            get_storage(:exists, true) << field
          when String, Symbol
            get_storage(:matches)[field] += Array(param)
            get_storage(:matchops)[field] = 'or'
          when Range
            get_storage(:ranges)[field] = Stretchy::Types::Range.new(param)
          else
            get_storage(:terms)[field] += Array(param)
          end
        end

    end
  end
end
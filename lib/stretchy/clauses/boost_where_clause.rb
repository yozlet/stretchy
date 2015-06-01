require 'stretchy/clauses/boost_clause'

module Stretchy
  module Clauses
      # 
      # Boosts documents that match certain filters. Most filters will
      # be passed into {#initialize}, but you can also use `.range` and 
      # `.geo` .
      # 
      # @author [atevans]
      # 
    class BoostWhereClause < BoostClause

      # 
      # Generates a boost that matches a set of filters.
      # 
      # @param base [Base] Query to copy data from.
      # @param options = {} [Hash] Fields and values to filter on.
      # 
      # @see {WhereClause#initialize}
      # 
      # @return [BoostWhereClause] Query with filter boosts applied
      def initialize(base, options = {})
        super(base)
        where_function(:init, options) if options.any?
        self
      end

      # 
      # Returns to the base context; filters passed here
      # will be used to filter documents.
      # 
      # @example Returning to base context
      #   query.boost.where(number_field: 33).where(other_field: 64)
      # 
      # @example Staying in boost context
      #   query.boost.where(number_field: 33).boost.where(other_field: 99)
      # 
      # @see {WhereClause#initialize}
      # 
      # @return [WhereClause] Query with where clause applied
      def where(*args)
        WhereClause.new(self, *args)
      end

      # 
      # Returns to the base context. Queries passed here
      # will be used to filter documents.
      # 
      # @example Returning to base context
      #   query.boost.where(number_field: 89).match('username')
      # 
      # @example Staying in boost context
      #   query.boost.where(number_field: 89).boost.match('love')
      # 
      # @see {MatchClause#initialize}
      # 
      # @return [MatchClause] Base context with match queries applied
      def match(*args)
        MatchClause.new(self, *args)
      end

      # 
      # Applies a range filter with a min or max
      # as a boost.
      # 
      # @see {WhereClause#range}
      # 
      # @see {Filters::RangeFilter}
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/guide/master/_ranges.html Elastic Guides - Ranges
      # 
      # @return [Base] Query in base context with range boost applied
      def range(*args)
        where_function(:range, *args)
        Base.new(self)
      end

      # 
      # Boosts a document if it matches a geo filter.
      # This is different than {BoostClause#near} -
      # while `.near` applies a decay function that boosts
      # based on how close a field is to a geo point,
      # `.geo` applies a filter that either boosts or doesn't
      # boost the document.
      # 
      # @see {WhereFunction#geo}
      # 
      # @see {Filters::GeoFilter}
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-distance-filter.html Elastic Docs - Geo Distance Filter
      # 
      # @return [Base] Query in base context with geo filter boost applied
      def geo(*args)
        where_function(:geo, *args)
        Base.new(self)
      end

      private

        def add_params(params = {})
          where_function(:init, params)
        end

        def where_function(method, *args)
          options   = args.last.is_a?(Hash) ? args.pop : {}
          weight    = options.delete(:weight)

          clause    = nil
          if method == :init
            clause  = WhereClause.tmp(options.merge(inverse: inverse?))
          else
            args.push(options)
            clause  = WhereClause.tmp(inverse: inverse?).send(method, *args)
          end
          boost     = clause.to_boost(weight)

          @boost_builder.functions << boost if boost
        end
    end
  end
end
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

      def boost_where(params = {}, options = {})
        weight = params.delete(:weight) || options[:weight]
        options[:inverse] = true if inverse?
        clause = WhereClause.new.where(params, options)
        boost  = clause.to_boost(weight)
        base.boost_builder.add_boost(boost) if boost
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
        WhereClause.new(base).where(*args)
      end

      def not(params = {}, options = {})
        @inverse = true
        boost_where(params, options)
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
        MatchClause.new(base).match(*args)
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
      def range(field, options = {})
        weight = options[:weight]
        options[:inverse] = true if inverse?
        
        clause = WhereClause.new.range(field, options)
        boost  = clause.to_boost(weight)
        base.boost_builder.add_boost(boost) if boost
        
        Base.new(base)
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
      def geo(field, options = {})
        weight = options[:weight]
        options[:inverse] = true if inverse?
        
        clause = WhereClause.new.geo(field, options)
        boost  = clause.to_boost(weight)
        base.boost_builder.add_boost(boost) if boost
        Base.new(base)
      end
    end
  end
end
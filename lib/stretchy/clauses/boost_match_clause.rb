require 'stretchy/clauses/boost_clause'

module Stretchy
  module Clauses
      # 
      # Boost documents that match a free-text query. Most
      # options will be passed into {#initialize}, but you 
      # can also chain `.not` onto it. Calling `.where` or
      # `.match` from here will apply filters (*not boosts*)
      # and return to the base state
      # 
      # @author [atevans]
      # 
    class BoostMatchClause < BoostClause

      delegate [:range, :geo] => :where

      # 
      # Adds a match query to the boost functions.
      # 
      # @overload initialize(base, opts_or_string)
      #   @param base [Base] Base query to copy data from
      #   @param opts_or_string [String] String to do a free-text match across the document
      # 
      # @overload initialize(base, opts_or_string)
      #   @param base [Base] Base query to copy data from
      #   @param options = {} [Hash] Fields and values to match via full-text search
      # 
      # @return [BoostMatchClause] Boost clause in match context, with queries applied
      def initialize(base, opts_or_string = {}, options = {})
        super(base)
        if opts_or_string.is_a?(Hash)
          match_function(opts_or_string.merge(options))
        else
          match_function(options.merge('_all' => opts_or_string))
        end
      end

      # 
      # Switches to inverse context, and applies filters as inverse
      # options (ie, documents that *do not* match the query will
      # be boosted)
      # 
      # @overload not(opts_or_string)
      #   @param [String] String that must not match anywhere in the document
      # 
      # @overload not(opts_or_string)
      #   @param opts_or_string [Hash] Fields and values that should not match in the document
      # 
      # @return [BoostMatchClause] Query with inverse matching boost function applied
      def not(opts_or_string = {})
        @inverse = true
        if opts_or_string.is_a?(Hash)
          match_function(opts_or_string)
        else
          match_function('_all' => opts_or_string)
        end
        self
      end

      # 
      # Returns to the base context; filters passed here
      # will be used to filter documents.
      # 
      # @example Returning to base context
      #   query.boost.match('string').where(other_field: 64)
      # 
      # @example Staying in boost context
      #   query.boost.match('string').boost.where(other_field: 99)
      # 
      # @see {WhereClause#initialize}
      # 
      # @return [WhereClause] Query with where clause applied
      def where(*args)
        WhereClause.new(base, *args)
      end

      # 
      # Returns to the base context. Queries passed here
      # will be used to filter documents.
      # 
      # @example Returning to base context
      #   query.boost.match(message: 'curse word').match('username')
      # 
      # @example Staying in boost context
      #   query.boost.match(message: 'happy word').boost.match('love')
      # 
      # @see {MatchClause#initialize}
      # 
      # @return [MatchClause] Base context with match queries applied
      def match(*args)
        MatchClause.new(base, *args)
      end

      private

        def match_function(options = {})
          weight = options.delete(:weight)
          clause = MatchClause.tmp(options)
          boost  = clause.to_boost(weight)
          base.boost_builder.functions << boost if boost
        end

    end
  end
end
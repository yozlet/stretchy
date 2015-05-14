require 'stretchy/clauses/base'

module Stretchy
  module Clauses
      # 
      # A Match clause inherits the same state as any clause.
      # There aren't any more specific methods to chain, as
      # this clause only handles basic full-text searches.
      # 
      # @author [atevans]
      # 
    class MatchClause < Base

      # 
      # Creates a temporary MatchClause outside the main
      # query scope by using a new {Base}. Primarily
      # used in {BoostClause} for boosting on full-text
      # matches.
      # 
      # @param options = {} [Hash] Options to pass to the full-text match
      # 
      # @return [MatchClause] Temporary clause outside current state
      def self.tmp(options = {})
        self.new(Base.new, options)
      end

      # 
      # Creates a new state with a match query applied.
      # 
      # @overload initialize(base, opts_or_string)
      #   @param [Base] Base clause to copy data from
      #   @param [String] Performs a full-text query for this string on all fields in the document.
      # 
      # @overload initialize(base, opts_or_string)
      #   @param [Base] Base clause to copy data from
      #   @param [Hash] A hash of fields and values to perform full-text matches with
      # 
      # @example A basic full-text match
      #   query.match("anywhere in document")
      # 
      # @example A full-text search on specific fields
      #   query.match(
      #     my_field: "match in my_field",
      #     other_field: "match in other_field"
      #   )
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html Elastic Docs - Match Query
      def initialize(base, opts_or_str = {}, options = {})
        super(base)
        if opts_or_str.is_a?(Hash)
          @inverse     = opts_or_str.delete(:inverse) || options.delete(:inverse)
          @should      = opts_or_str.delete(:should)  || options.delete(:should)
          add_params(options.merge(opts_or_str))
        else
          @inverse     = options.delete(:inverse)
          @should      = options.delete(:should)
          add_params(options.merge('_all' => opts_or_str))
        end
      end

      # 
      # Switches to inverted context. Matches applied here work the same way as
      # {#initialize}, but returned documents must **not** match these filters.
      # 
      # @overload not(opts_or_str)
      #   @param [String] A string that must not be matched anywhere in the document
      # @overload not(opts_or_str)
      #   @param [Hash] A hash of fields and strings that must not be matched in those fields
      # 
      # @return [MatchClause] inverted query state with match filters applied
      # 
      # @example Inverted full-text
      #   query.match.not("hello")
      # 
      # @example Inverted full-text matching for specific fields
      #   query.match.not(
      #     my_field: "not_match_1",
      #     other_field: "not_match_2"
      #   )
      def not(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(inverse: true, should: should?))
      end

      # 
      # Switches to `should` context. Applies full-text matches
      # that are not required, but boost the relevance score for
      # matching documents.
      # 
      # Can be chained with {#not}
      # 
      # @overload not(opts_or_str)
      #   @param [String] A string that should be matched anywhere in the document
      # @overload not(opts_or_str)
      #   @param [Hash] A hash of fields and strings that should be matched in those fields
      # 
      # @param opts_or_str = {} [type] [description]
      # @param options = {} [type] [description]
      # 
      # @return [MatchClause] query state with should filters added
      # 
      # @example Should match with full-text
      #   query.match.should("anywhere")
      # 
      # @example Should match specific fields
      #   query.match.should(
      #     field_one: "one",
      #     field_two: "two"
      #   )
      # 
      # @example Should not match
      #   query.match.should.not(
      #     field_one: "one",
      #     field_two: "two"
      #   )
      # 
      # @see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html Elastic Docs - Bool Query
      def should(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(should: true))
      end

      # 
      # Converts this match context to a set of boosts
      # to use in a {Stretchy::Queries::FunctionScoreQuery}
      # 
      # @param weight = nil [Numeric] Weight of generated boost
      # 
      # @return [Stretchy::Boosts::FilterBoost] boost containing these match parameters
      def to_boost(weight = nil)
        weight ||= Stretchy::Boosts::FilterBoost::DEFAULT_WEIGHT
        Stretchy::Boosts::FilterBoost.new(
          filter: Stretchy::Filters::QueryFilter.new(
            @match_builder.build
          ),
          weight: weight
        )
      end

      # 
      # Accessor for `@should`
      # 
      # @return [true, false] `@should`
      def should?
        !!@should
      end

      private

        def get_storage
          if inverse?
            if should?
              @match_builder.shouldnotmatches
            else
              @match_builder.antimatches
            end
          else
            if should?
              @match_builder.shouldmatches
            else
              @match_builder.matches
            end
          end
        end

        def add_params(params = {})
          case params
          when Hash
            params.each do |field, params|
              add_param(field, params)
            end
          else
            add_param('_all', params)
          end
        end

        def add_param(field, param)
          get_storage[field] += Array(param)
        end

    end
  end
end
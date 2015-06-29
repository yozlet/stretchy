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

      FULLTEXT_SLOP = 50
      FULLTEXT_MIN  = 1

      def match(params = {}, options = {})
        @inverse = false unless should?
        add_params(hashify_params(params), options)
        self
      end

      #
      # Specifies that values for this field should be
      # matched with a proximity boost, rather than as
      # a generic match query.
      #
      # This means searching for "quick brown fox" will
      # return matches in the following order:
      #
      # * "the quick brown fox jumped over"
      # * "the brown quick fox jumped over"
      # * "the fox, brown & quick jumped over"
      # * "the quick fox jumped over"
      # * "the quick green and purple sparkly fox jumped over"
      # * "the quick dog jumped over"
      # * "the adoreable puppy jumped over" **not returned**
      #
      # @overload phrase(params)
      #   @param params = {} [String] A phrase that will
      #     be matched anywhere in the document
      #
      # @overload phrase(params)
      #   @param params = {} [Hash] A hash of fields and phrases
      #     that should be matched in those fields
      #
      # @example Matching multiple words together
      #   query.match.phrase('hugs and love')
      #
      # @example Not matching a phrase
      #   query.match.not.phrase(comment: 'offensive words to hide')
      #
      # @return [self] Allows continuing the query chain
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/guide/current/proximity-relevance.html Elasticsearch guide: proximity for relevance
      def fulltext(params = {})
        add_params(params)
        add_params(params, should: true, slop: FULLTEXT_SLOP)
        self
      end

      #
      # Adds a MoreLikeThis query to the chain. Pass in document ids,
      # an array of index/name/ids, or a string to get documents that
      # have similar terms.
      #
      # This method accepts all the options in the Elasticsearch
      # `more_like_this` query, which are pretty extensive. See the
      # documentation (link below) to get an idea of what is available.
      #
      # Only one of `:docs`, `:ids`, or `:like_text` is required, and
      # one of those three must be present.
      #
      # @param params = {} [Hash] Params used to build the `more_like_this` query
      #   @option params [Array] :like_text A string to compare documents do
      #   @option params [Array] :ids A list of document ids to compare documents to
      #   @option params [Array] :docs An array of document hashes. You can pass the
      #     results of another query here, or a hash with fields '_index', '_type'
      #     and '_id'
      #   @option params [Array] :fields A list of fields to use in the comparison.
      #     Defaults to '_all'
      #   @option params [Array] :include Whether the source documents should be
      #     included in the result set. Defaults to `false`
      #
      # @return [MatchClause] allows continuing the query chain
      #
      # @example Getting more like a document by id
      #   query.more_like(ids: other_result_id)
      #
      # @example Getting more like a document from another query
      #   query.more_like(docs: other_query.results)
      #
      # @example Getting more like a document from a string
      #   query.more_like(like_text: 'puppies and kittens are great')
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-mlt-query.html Elasticsearch more-like-this query documentation
      #
      def more_like(params = {}, options = {})
        query = Queries::MoreLikeThisQuery.new(params)
        options[:inverse] = true if inverse?
        options[:should]  = true if should?

        base.add_query(query, options)
        self
      end

      #
      # Switches to inverted context. Matches applied here work the same way as
      # {#initialize}, but returned documents must **not** match these filters.
      #
      # @overload not(params)
      #   @param [String] A string that must not be matched anywhere in the document
      # @overload not(params)
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
      def not(params = {}, options = {})
        @inverse = true
        add_params(params, options)
        self
      end

      #
      # Switches to `should` context. Applies full-text matches
      # that are not required, but boost the relevance score for
      # matching documents.
      #
      # Can be chained with {#not}
      #
      # @overload should(params)
      #   @param [String] A string that should be matched anywhere in the document
      # @overload should(params)
      #   @param [Hash] A hash of fields and strings that should be matched in those fields
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
      def should(params = {}, options = {})
        @should  = true
        @inverse = false
        add_params(params, options)
        self
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
            base.match_builder.to_query
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

        def add_params(params = {}, options = {})
          case params
          when Hash
            params.each do |field, params|
              add_param(field, params, options)
            end
          else
            add_param('_all', params, options)
          end
        end

        def add_param(field, param, options = {})
          options[:inverse] = true if inverse? || options[:inverse]
          options[:should]  = true if should?  || options[:should]
          base.match_builder.add_matches(field, param, options)
        end

    end
  end
end

module Stretchy
  module Builders
    class BoostBuilder

      attr_accessor :functions, :overall_boost, :max_boost, :score_mode, :boost_mode

      def initialize
        @functions      = []
        @overall_boost  = nil
        @max_boost      = nil
        @score_mode     = 'sum'
        @boost_mode     = 'sum'
      end

      def any?
        @functions.any?
      end

      def to_search(query_or_filter)
        options = { 
          functions:  @functions,
          score_mode: @score_mode,
          boost_mode: @boost_mode
        }
        
        options[:overall_boost] = @overall_boost if @overall_boost
        options[:max_boost]     = @max_boost if @max_boost
        options[:query]         = query_or_filter if query_or_filter.is_a?(Stretchy::Queries::Base)
        options[:filter]        = query_or_filter if query_or_filter.is_a?(Stretchy::Filters::Base)
        
        Stretchy::Queries::FunctionScoreQuery.new(options)
      end

    end
  end
end
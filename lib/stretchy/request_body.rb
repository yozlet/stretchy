module Search
  class RequestBody

    def initialize(options = {})
      @json         = {}
      @match        = options[:match]
      @filters      = options[:filters]
      @not_filters  = options[:not_filters]
      @boosts       = options[:boosts]
      @offset       = options[:offset] || 0
      @limit        = options[:limit]  || Query::DEFAULT_LIMIT
      @explain      = options[:explain]
    end

    def to_search
      return @json if @json.present?
      query = @match.present? ? @match : Queries::MatchAllQuery.new

      if @filters.present? && @not_filters.present?
        query = Queries::FilteredQuery.new(
          query: query,
          filter: Filters::BoolFilter.new(
            must: @filters,
            must_not: @not_filters
          )
        )
      elsif @filters.present?
        if @filters.count == 1
          query = Queries::FilteredQuery.new(
            query: query,
            filter: @filters.first
          )
        else
          query = Queries::FilteredQuery.new(
            query: query,
            filter: Filters::AndFilter.new(@filters)
          )
        end
      elsif @not_filters.present?
        query = Queries::FilteredQuery.new(
          query: query,
          filter: Filters::NotFilter.new(@not_filters)
        )
      end

      if @boosts.present?
        query = Queries::FunctionScoreQuery.new(
          query: query,
          functions: @boosts,
          score_mode: 'sum',
          boost_mode: 'max'
        )
      end

      @json = {}
      @json[:query]   = query.to_search
      @json[:from]    = @offset
      @json[:size]    = @limit
      @json[:explain] = @explain if @explain

      # not a ton of output, usually worth having
      Rails.logger.debug(Colorize.green("Generated elastic query: #{JSON.pretty_generate(@json)}"))
      @json
    end
  end
end

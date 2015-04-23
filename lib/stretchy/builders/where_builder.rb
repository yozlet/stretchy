module Stretchy
  module Builders
    class WhereBuilder

      attr_accessor :matches, :antimatches, :terms, :antiterms,
                    :exists, :empties, :ranges, :antiranges,
                    :geos, :antigeos

      def initialize(options = {})
        @matches      = Hash.new { [] }
        @antimatches  = Hash.new { [] }
        @terms        = Hash.new { [] }
        @antiterms    = Hash.new { [] }
        @ranges       = {}
        @antiranges   = {}
        @geos         = {}
        @antigeos     = {}

        @exists       = []
        @empties      = []
      end

      def to_search
        query = Stretchy::Queries::MatchAllQuery.new
        puts @matches.inspect
        query = match_query(@matches) if @matches.any?

        if musts? || must_nots?
          query = Stretchy::Queries::FilteredQuery.new(query: query, filter: build_filter)
        end

        query.to_search
      end

      def musts?
        @terms.any? || @exists.any? || @ranges.any? || @geos.any?
      end

      def must_nots?
        @antiterms.any?   || @empties.any?    || 
        @antimatches.any? || @antiranges.any? || 
        @antigeos.any?
      end

      def use_bool?
        musts? && must_nots?
      end

      def build_filter
        if use_bool?
          bool_filter
        elsif musts?
          and_filter
        elsif must_nots?
          not_filter
        else
          nil
        end
      end

      def bool_filter
        Stretchy::Filters::BoolFilter.new(
          must: build_filters(
            terms: @terms,
            exists: @exists,
            ranges: @ranges,
            geos: @geos
          ),
          must_not: build_filters(
            terms: @antiterms,
            exists: @empties,
            matches: @antimatches,
            ranges: @antiranges,
            geos: @antigeos
          )
        )
      end

      def and_filter
        filter = build_filters(
          terms:  @terms,
          exists: @exists,
          ranges: @ranges,
          geos:   @geos
        )
        filter = Stretchy::Filters::AndFilter.new(filter) if filter.count > 1
        filter
      end

      def not_filter
        filter = build_filters(
          terms:    @antiterms,
          exists:   @empties,
          matches:  @antimatches,
          ranges:   @antiranges,
          geos:     @antigeos
        )
        filter = Stretchy::Filters::AndFilter.new(filter) if filter.count > 1
        Stretchy::Filters::NotFilter.new(filter)
      end

      def build_filters(options = {})
        filters = []
        terms   = Hash(options[:terms])
        matches = Hash(options[:matches])
        ranges  = Hash(options[:ranges])
        geos    = Hash(options[:geos])
        exists  = Array(options[:exists])
        
        filters << Stretchy::Filters::TermsFilter.new(terms) if terms.any?
        
        filters += exists.map do |field|
          Stretchy::Filters::ExistsFilter.new(field)
        end

        filters += ranges.map do |field, values|
          Stretchy::Filters::RangeFilter.new(
            field:  field,
            min:    values[:min],
            max:    values[:max]
          )
        end

        filters += geos.map do |field, values|
          Stretchy::Filters::GeoFilter.new(
            field: field,
            distance: values[:distance],
            lat: values[:lat],
            lng: values[:lng]
          )
        end
        
        filters << Stretchy::Filters::QueryFilter.new(match_query(matches)) if matches.any?
        filters
      end

      def match_query(params)
        match_data = params.map do |name, terms|
          {
            name: name,
            query: terms.join(' '),
            operator: 'and'
          }
        end

        Stretchy::Queries::MatchQuery.new(match_data) unless match_data.empty?
      end
    end
  end
end
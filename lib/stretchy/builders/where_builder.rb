module Stretchy
  module Builders
    class WhereBuilder

      attr_accessor :terms, :antiterms, :exists, :empties, 
                    :ranges, :antiranges, :geos, :antigeos

      def initialize(options = {})
        @terms        = Hash.new { [] }
        @antiterms    = Hash.new { [] }
        @ranges       = {}
        @antiranges   = {}
        @geos         = {}
        @antigeos     = {}

        @exists       = []
        @empties      = []
      end

      def build
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

      def musts?
        @terms.any? || @exists.any? || @ranges.any? || @geos.any?
      end

      def must_nots?
        @antiterms.any?   || @empties.any?    || 
        @antiranges.any?  || @antigeos.any?
      end

      def use_bool?
        musts? && must_nots?
      end

      def any?
        musts? || must_nots?
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
            ranges: @antiranges,
            geos: @antigeos
          )
        )
      end

      def and_filter
        filter = nil
        filters = build_filters(
          terms:  @terms,
          exists: @exists,
          ranges: @ranges,
          geos:   @geos
        )
        if filters.count > 1
          filter = Stretchy::Filters::AndFilter.new(filters)
        else
          filter = filters.first
        end
        filter
      end

      def not_filter
        filter = build_filters(
          terms:    @antiterms,
          exists:   @empties,
          ranges:   @antiranges,
          geos:     @antigeos
        )
        filter = Stretchy::Filters::AndFilter.new(filter) if filter.count > 1
        Stretchy::Filters::NotFilter.new(filter)
      end

      def build_filters(options = {})
        filters = []
        terms   = Hash(options[:terms])
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
        filters
      end
    end
  end
end
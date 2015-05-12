module Stretchy
  module Builders
    class WhereBuilder

      attr_accessor :terms,   :antiterms,   :shouldterms,   :shouldnotterms,
                    :exists,  :antiexists,  :shouldexists,  :shouldnotexists,
                    :ranges,  :antiranges,  :shouldranges,  :shouldnotranges,
                    :geos,    :antigeos,    :shouldgeos,    :shouldnotgeos

      def initialize(options = {})
        @terms            = Hash.new { [] }
        @antiterms        = Hash.new { [] }
        @shouldterms      = Hash.new { [] }
        @shouldnotterms   = Hash.new { [] }
        
        @ranges           = {}
        @antiranges       = {}
        @shouldranges     = {}
        @shouldnotranges  = {}
        
        @geos             = {}
        @antigeos         = {}
        @shouldgeos       = {}
        @shouldnotgeos    = {}

        @exists           = []
        @antiexists       = []
        @shouldexists     = []
        @shouldnotexists  = []
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
        @antiterms.any?   || @antiexists.any? || 
        @antiranges.any?  || @antigeos.any?
      end

      def shoulds?
        @shouldterms.any?       ||
        @shouldranges.any?      ||
        @shouldgeos.any?        ||
        @shouldexists.any?
      end

      def should_nots?
        @shouldnotterms.any?    ||
        @shouldnotranges.any?   ||
        @shouldnotgeos.any?     ||
        @shouldnotexists.any?
      end

      def use_bool?
        (musts? && must_nots?) || shoulds? || should_nots?
      end

      def any?
        musts? || must_nots? || shoulds? || should_nots?
      end

      def bool_filter
        Stretchy::Filters::BoolFilter.new(
          must: build_filters(
            terms:  @terms,
            exists: @exists,
            ranges: @ranges,
            geos:   @geos
          ),
          must_not: build_filters(
            terms:  @antiterms,
            exists: @antiexists,
            ranges: @antiranges,
            geos:   @antigeos
          ),
          should: build_should
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
          exists:   @antiexists,
          ranges:   @antiranges,
          geos:     @antigeos
        )
        filter = Stretchy::Filters::OrFilter.new(filter) if filter.count > 1
        Stretchy::Filters::NotFilter.new(filter)
      end

      def build_should
        if shoulds? && should_nots?
          Stretchy::Filters::BoolFilter.new(
            must: build_filters(
              terms:  @shouldterms,
              exists: @shouldexists,
              ranges: @shouldranges,
              geos:   @shouldgeos
            ),
            must_not: build_filters(
              terms:  @shouldnotterms,
              exists: @shouldnotexists,
              ranges: @shouldnotranges,
              geos:   @shouldnotgeos
            )
          )
        elsif should_nots?
          filters = build_filters(
            terms:  @shouldnotterms,
            exists: @shouldnotexists,
            ranges: @shouldnotranges,
            geos:   @shouldnotgeos
          )
          if filters.count > 1
            filters = Stretchy::Filters::OrFilter.new(filters) 
          else
            filters = filters.first
          end
          
          Stretchy::Filters::NotFilter.new(filters)
        else
          filters = build_filters(
            terms:  @shouldterms,
            exists: @shouldexists,
            ranges: @shouldranges,
            geos:   @shouldgeos
          )
          filters = Stretchy::Filters::AndFilter.new(filters) if filters.count > 1
          filters
        end
      end

      def build_filters(options = {})
        filters = []
        terms       = Hash(options[:terms])
        ranges      = Hash(options[:ranges])
        geos        = Hash(options[:geos])
        near_fields = Hash(options[:near_fields])
        exists      = Array(options[:exists])
        
        terms.each do |field, values|
          filters << Stretchy::Filters::TermsFilter.new(field, values)
        end
        
        filters += exists.map do |field|
          Stretchy::Filters::ExistsFilter.new(field)
        end

        filters += ranges.map do |field, value|
          Stretchy::Filters::RangeFilter.new(field: field, stretchy_range: value)
        end

        filters += geos.map do |field, values|
          Stretchy::Filters::GeoFilter.new(
            field: field,
            distance: values[:distance],
            geo_point: values[:geo_point],
            lat: values[:lat],
            lng: values[:lng]
          )
        end
        filters
      end
    end
  end
end
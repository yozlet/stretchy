module Stretchy
  module Builders
    class FilterBuilder

      attr_reader :terms, :ranges, :geos, :exists, :filters, :inverse, :should

      def initialize
        @terms    = Hash.new { [] }
        @ranges   = Hash.new { [] }
        @geos     = Hash.new { [] }
        @filters   = []
        @exists   = []
      end

      def any?
        [@filters, @terms, @ranges, @geos, @exists].any?(&:any?)
      end

      def add_filter(filter)
        @filters << filter
      end

      def add_terms(field, terms)
        @terms[field] += Array(terms)
        @terms[field].uniq!
      end

      def add_range(field, options)
        @ranges[field] = Filters::RangeFilter.new(field, options)
      end

      def add_geo(field, distance, geo_point)
        @geos[field] = Filters::GeoFilter.new(field, distance, geo_point)
      end

      def add_exists(fields)
        @exists += clean_string_array(fields)
        @exists.uniq!
      end

      def to_filters
        _filters = @ranges.values + @geos.values
        _filters += @terms.map do |field, values|
          Filters::TermsFilter.new(field, values)
        end

        _filters += @exists.map {|field| Filters::ExistsFilter.new(field) }
        filters + _filters
      end

      private
        def clean_string_array(values)
          Array(values).map(&:to_s).map(&:strip).reject(&:empty?)
        end

    end
  end
end

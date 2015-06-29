module Stretchy
  module Builders
    class FilterBuilder

      attr_reader :terms, :ranges, :geos, :exists, :params, :inverse, :should

      def initialize
        @terms    = Hash.new { [] }
        @ranges   = Hash.new { [] }
        @geos     = Hash.new { [] }
        @params   = []
        @exists   = []
      end

      def any?
        [@params, @terms, @ranges, @geos, @exists].any?(&:any?)
      end

      def add_params(params)
        @params << Filters::ParamsFilter.new(params)
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
        filters = @ranges.values + @geos.values
        filters += @terms.map do |field, values|
          Filters::TermsFilter.new(field, values)
        end

        filters += @exists.map {|field| Filters::ExistsFilter.new(field) }
        filters + params
      end

      private
        def clean_string_array(values)
          Array(values).map(&:to_s).map(&:strip).reject(&:empty?)
        end

    end
  end
end

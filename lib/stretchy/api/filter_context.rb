require 'stretchy/api/context'

module Stretchy
  module API
    class FilterContext < Context

      def raw(params = {}, options = {})
        current.add_filter(
          Nodes::Filters::ParamsFilter.new(params: params),
          options
        )
        base
      end

      def terms(params = {}, options = {})
        params.each do |field, val|
          current.add_filter(
            Nodes::Filters::TermsFilter.new(field: field, terms: Array(val)),
            options
          )
        end
        base
      end

      def range(params = {}, options = {})
        range_value = Nodes::Types::Range.new(params)

        current.add_filter(
          Nodes::Filters::RangeFilter.new(
            field: params[:field],
            range: range_value
          ),
          options
        )
        base
      end

      def geo_distance(params = {}, options = {})
        geo_point = Nodes::Types::GeoPoint.new(params)

        current.add_filter(
          Nodes::Filters::GeoFilter.new(
            params.merge(geo_point: geo_point)
          ),
          options
        )
        base
      end

      def exists(*fields, **options)
        fields.each do |field|
          current.add_filter(
            Nodes::Filters::ExistsFilter.new(field: field),
            options
          )
        end
        base
      end

    end
  end
end

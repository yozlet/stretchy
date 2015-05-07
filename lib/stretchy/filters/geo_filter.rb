require 'stretchy/filters/base'
require 'stretchy/types/geo_point'

module Stretchy
  module Filters
    class GeoFilter < Base

      contract distance: {type: :distance, required: true},
              geo_point: {type: Stretchy::Types::GeoPoint, required: true},
                  field: {type: :field, required: true}

      def initialize(options = {})
        @field      = options[:field]
        @distance   = options[:distance]
        @geo_point  = options[:geo_point] || Stretchy::Types::GeoPoint.new(options)
        validate!
      end

      def to_search
        {
          geo_distance: {
            distance: @distance,
            @field => @geo_point.to_search
          }
        }
      end
    end
  end
end

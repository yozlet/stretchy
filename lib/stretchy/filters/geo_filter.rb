require 'stretchy/filters/base'
require 'stretchy/types/geo_point'

module Stretchy
  module Filters
    class GeoFilter < Base

      attribute :field
      attribute :distance
      attribute :geo_point

      validations do
        rule :field,       field: { required: true }
        rule :geo_point,   type: {classes: Types::GeoPoint}
        rule :distance,   :distance
      end

      def initialize(field, distance, geo_point)
        @field      = field
        @distance   = distance
        @geo_point  = Types::GeoPoint.new(geo_point)
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

require 'stretchy/nodes/filters/base'
require 'stretchy/nodes/types/geo_point'

module Stretchy
  module Nodes
    module Filters
      class GeoFilter < Base

        attribute :field
        attribute :distance
        attribute :geo_point

        validations do
          rule :field,       field: { required: true }
          rule :geo_point,   type:  Types::GeoPoint
          rule :distance,    :distance
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
end

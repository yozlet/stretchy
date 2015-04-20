module Stretchy
  module Filters
    class GeoFilter < Base

      contract distance: {type: :distance},
                    lat: {type: :lat},
                    lng: {type: :lng},
                  field: {type: :field}

      def initialize(field: 'coords', distance: '50km', lat:, lng:)
        @field    = field
        @distance = distance
        @lat      = lat
        @lng      = lng
        validate!
      end

      def to_search
        {
          geo_distance: {
            distance: @distance,
            @field => {
              lat: @lat,
              lon: @lng
            }
          }
        }
      end
    end
  end
end

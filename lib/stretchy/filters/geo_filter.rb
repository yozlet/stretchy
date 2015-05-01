module Stretchy
  module Filters
    class GeoFilter < Base

      contract distance: {type: :distance, required: true},
                    lat: {type: :lat, required: true},
                    lng: {type: :lng, required: true},
                  field: {type: :field, required: true}

      def initialize(options = {})
        @field    = options[:field]
        @distance = options[:distance]
        @lat      = options[:lat]
        @lng      = options[:lng]
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

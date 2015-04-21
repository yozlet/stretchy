module Stretchy
  module Boosts
    class GeoBoost < Base

      DEFAULTS = {
        field: 'coords',
        offset: '10km',
        scale: '50km',
        decay: 0.75,
        weight: 1.2
      }.freeze

      contract offset: {type: :distance},
                scale: {type: :distance},
                decay: {type: Numeric},
               weight: {type: Numeric},
                  lat: {type: :lat},
                  lng: {type: :lng}

      def initialize(options = {})
        @field  = options[:field]   || DEFAULTS[:field]
        @offset = options[:offset]  || DEFAULTS[:offset]
        @scale  = options[:scale]   || DEFAULTS[:scale]
        @decay  = options[:decay]   || DEFAULTS[:decay]
        @weight = options[:weight]  || DEFAULTS[:weight]
        @lat    = options[:lat]
        @lng    = options[:lng]
        validate!
      end

      def to_search
        {
          gauss: {
            @field => {
              origin: { lat: @lat, lon: @lng },
              offset: @offset,
              scale: @scale,
              decay: @decay
            }
          },
          weight: @weight
        }
      end
    end
  end
end

module Search
  module Boosts
    class GeoBoost

      def initialize(options = {})
        @field  = options[:field]   || 'coords'
        @offset = options[:offset]  || '10km'
        @scale  = options[:scale]   || '50km'
        @decay  = options[:decay]   || 0.75
        @weight = options[:weight]  || 1
        @lat    = options[:lat]
        @lng    = options[:lng]
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

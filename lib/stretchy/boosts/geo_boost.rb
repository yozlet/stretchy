require 'stretchy/boosts/base'
require 'stretchy/types/geo_point'

module Stretchy
  module Boosts
    class GeoBoost < Base

      DEFAULTS = {
        offset: '10km',
        decay: 0.75,
        weight: 1.2
      }.freeze

      contract offset: {type: :distance},
                scale: {type: :distance, required: true},
                decay: {type: Numeric},
               weight: {type: Numeric},
            geo_point: {type: Stretchy::Types::GeoPoint, required: true}

      def initialize(options = {})
        @field      = options[:field]
        @scale      = options[:scale]
        @offset     = options[:offset]    || DEFAULTS[:offset]
        @decay      = options[:decay]     || DEFAULTS[:decay]
        @weight     = options[:weight]    || DEFAULTS[:weight]
        @geo_point  = options[:geo_point] || Stretchy::Types::GeoPoint.new(options)
        validate!
      end

      def to_search
        {
          gauss: {
            @field => {
              origin: @geo_point.to_search,
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

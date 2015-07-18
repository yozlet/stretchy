require 'stretchy/nodes/types/base'

module Stretchy
  module Nodes
    module Types
      class GeoPoint < Base

        attribute :lat
        attribute :lon

        validations do
          rule :lat, :latitude
          rule :lon, :longitude
        end

        attr_reader :lat, :lon

        def initialize(options = {})
          if options.is_a?(self.class)
            @lat = options.lat
            @lon = options.lon
          else
            @lat = options[:lat] || options[:latitude]
            @lon = options[:lng] || options[:lon] ||
                   options[:longitude]
          end

          validate!
        end

        def to_search
          {
            lat: @lat,
            lon: @lon
          }
        end

      end
    end
  end
end

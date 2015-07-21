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

        def after_initialize(options = {})
          @lon ||= options[:lng] || options[:longitude]
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

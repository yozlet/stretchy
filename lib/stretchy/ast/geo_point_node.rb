require 'stretchy/ast/base'

module Stretchy
  module AST
    class GeoPointNode < Base

      attribute :lat
      attribute :lon

      validations do
        rule :lat, :latitude
        rule :lon, :longitude
      end

      def self.from_options(options = {})
        return options[:geo_point] if options[:geo_point] && options[:geo_point].is_a?(self)
        options.is_a?(self) ? options : self.new(options)
      end

      def after_initialize(options = {})
        @lat ||= options[:latitude]
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

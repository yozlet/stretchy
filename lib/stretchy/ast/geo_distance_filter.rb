require 'stretchy/ast/base'
require 'stretchy/ast/geo_point_node'

module Stretchy
  module AST
    class GeoDistanceFilter < Base

      attribute :field,    String
      attribute :distance, String
      attribute :geo_point

      validations do
        rule :field,       field: { required: true }
        rule :geo_point,   type:  { classes: GeoPointNode }
        rule :distance,    :distance
      end

      def after_initialize(options = {})
        @geo_point = GeoPointNode.from_options(options)
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

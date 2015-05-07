require 'stretchy/boosts/base'
require 'stretchy/types/geo_point'

module Stretchy
  module Boosts
    class FieldDecayBoost < Base

      attr_reader :field, :origin, :scale, :offset, :decay, :decay_amount, :weight

      contract field: {type: :field, required: true},
              origin: {required: true, type: [Numeric, Time, Date, Stretchy::Types::GeoPoint]},
               scale: {required: true},
               decay: {type: Numeric},
                type: {type: :decay}

      def initialize(options = {})
        @field        = options[:field]
        @origin       = options[:origin]
        @scale        = options[:scale]
        
        @offset       = options[:offset]
        @type         = options[:type]    || DEFAULT_DECAY_FN
        @weight       = options[:weight]  || DEFAULT_WEIGHT
        @decay        = options[:decay]
        
        validate!
      end

      def to_search
        json = {
          origin: @origin,
          scale: @scale,
        }
        json[:offset] = @offset  if @offset
        json[:decay]  = @decay   if @decay

        {
          @type => {
            @field => json
          },
          weight: @weight
        }
      end

    end
  end
end
require 'stretchy/nodes/boosts/base'
require 'stretchy/nodes/types/geo_point'

module Stretchy
  module Nodes
    module Boosts
      class FieldDecayBoost < Base

        DEFAULT_DECAY_FN = :gauss

        attribute :field
        attribute :origin
        attribute :scale
        attribute :offset
        attribute :decay,         Symbol, default: DEFAULT_DECAY_FN
        attribute :decay_amount,  Float,  default: DEFAULT_WEIGHT
        attribute :weight

        validations do
          rule :field,         field: { required: true }
          rule :origin,        type:  { classes: [Numeric, Time, Date, Types::GeoPoint], required: true }
          rule :decay_amount,  type:  Numeric
          rule :scale,         :required
          rule :decay,         :decay
        end

        def to_search
          json = {scale: @scale}

          if @origin.is_a?(Types::Base)
            json[:origin] = @origin.to_search
          else
            json[:origin] = @origin
          end

          json[:offset]   = @offset  if @offset
          json[:decay]    = @decay_amount   if @decay_amount

          {
            @decay => {
              @field => json
            },
            weight: @weight
          }
        end

      end
    end
  end
end

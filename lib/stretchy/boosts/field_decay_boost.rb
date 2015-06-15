require 'stretchy/boosts/base'
require 'stretchy/types/geo_point'

module Stretchy
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
        rule :origin,        type: {classes: [Numeric, Time, Date, Stretchy::Types::GeoPoint], required: true}
        rule :scale,        :required
        rule :decay,        :decay
        rule :decay_amount,  type: {classes: Numeric}
      end

      def initialize(options = {})
        self.class.attribute_set.set(self, options) if options
        set_default_attributes

        validate!
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
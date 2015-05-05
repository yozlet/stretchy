module Stretchy
  module Boosts
    class FieldDecayBoost < Base

      contract field: {type: :field},
              origin: {required: true},
               scale: {required: true},
               decay: {type: :decay}

      def initialize(options = {})
        @field  = options[:field]
        @origin = options[:origin]
        @offset = options[:offset]
        @scale  = options[:scale] 
        @decay  = options[:decay]   || :gauss
        @weight = options[:weight]  || DEFAULT_WEIGHT
      end

      def to_search
        json = {
          origin: @origin,
          scale: @scale,
        }
        json[:offset] = @offset   if @offset
        json[:decay]  = @decay    if @decay

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
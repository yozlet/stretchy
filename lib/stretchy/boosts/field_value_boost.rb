module Stretchy
  module Boosts
    class FieldValueBoost < Base

      MODIFIERS = [:none, :log, :log1p, :log2p, :ln, :ln1p, :ln2p, :square, :sqrt, :reciprocal]

      attribute :field
      attribute :modifier
      attribute :factor

      validations do
        rule :field,    field: { required: true }
        rule :modifier, inclusion: {in: MODIFIERS}
        rule :factor,   type: {classes: Numeric}
      end

      def initialize(field, options = {})
        @field    = field
        @modifier = options[:modifier]
        @factor   = options[:factor]
        validate!
      end

      def to_search
        json = { field: field }
        json[:modifier] = modifier if modifier
        json[:factor] = factor if factor
        
        {
          field_value_factor: json
        }
      end

    end
  end
end
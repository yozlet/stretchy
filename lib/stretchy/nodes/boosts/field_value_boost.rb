require 'stretchy/nodes/boosts/base'

module Stretchy
  module Nodes
    module Boosts
      class FieldValueBoost < Base

        MODIFIERS = [:none, :log, :log1p, :log2p, :ln, :ln1p, :ln2p, :square, :sqrt, :reciprocal]

        attribute :field
        attribute :modifier
        attribute :factor

        validations do
          rule :field,    field:     { required: true }
          rule :modifier, inclusion: { in: MODIFIERS  }
          rule :factor,   type:      Numeric
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
end

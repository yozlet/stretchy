require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters
      class NotFilter < Base

        attribute :filters, Array[Base]

        validations do
          rule :filters, type: { classes: Base, array: true }
          rule :filters, :not_empty
        end

        def to_search
          { not: filter.to_search }
        end
      end
    end
  end
end

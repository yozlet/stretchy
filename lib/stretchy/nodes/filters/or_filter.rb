require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters
      class OrFilter < Base

        attribute :filters, Array[Base]

        validations do
          rule :filters, type: {classes: Base, array: true}
        end

        def add_filter(node, options = {})
          @filters << node
        end

        def to_search
          {
            or: @filters.map(&:to_search)
          }
        end

      end
    end
  end
end

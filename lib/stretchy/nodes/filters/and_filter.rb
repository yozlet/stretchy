require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters
      class AndFilter < Base

        attribute :filters

        validations do
          rule :filters, type: {classes: Filters::Base, array: true}
        end

        def add_filter(node, options = {})
          @filters << node
        end

        def to_search
          {
            and: @filters.map(&:to_search)
          }
        end

      end
    end
  end
end

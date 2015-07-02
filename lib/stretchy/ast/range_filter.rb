require 'stretchy/ast/base'
require 'stretchy/ast/range_node'

module Stretchy
  module AST
    class RangeFilter < Base

      attribute :field, String
      attribute :range, RangeNode

      validations do
        rule :field, field: { required: true }
        rule :range, type:  { classes: RangeNode }
      end

      def after_initialize(options = {})
        @range ||= RangeNode.from_options(options)
      end

      def to_search
        {
          range: {
            @field => @range.to_search
          }
        }
      end
    end
  end
end

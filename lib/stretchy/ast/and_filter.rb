require 'stretchy/ast/base'

module Stretchy
  module AST
    class AndFilter < Base

      attribute :filters

      validations do
        rule :filters, :not_empty
        rule :filters, type: {classes: Base, array: true}
      end

      def after_initialize(options = {})
        @filters = Array(filters)
      end

      def simplify
        filters.count > 1 ? self : filters.first
      end

      def to_search
        { and: filters.map(&:to_search) }
      end

    end
  end
end

require 'stretchy/ast/base'

module Stretchy
  module AST
    class NotFilter < Base

      attribute :filter, Base

      validations do
        rule :filter, type: Base
      end

      def simplify
        self.class.new(filter: filter.simplify)
      end

      def to_search
        { not: filter.to_search }
      end
    end
  end
end

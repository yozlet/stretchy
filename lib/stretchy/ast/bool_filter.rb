require 'stretchy/ast/base'

module Stretchy
  module AST
    class BoolFilter < Base

      attribute :must,     Array[Base], default: []
      attribute :must_not, Array[Base], default: []
      attribute :should,   Array[Base], default: []

      validations do
        rule :must,     type: {classes: Base, array: true}
        rule :must_not, type: {classes: Base, array: true}
        rule :should,   type: {classes: Base, array: true}
      end

      def simplify
        return self if should.any? || (must.any? && must_not.any?)
        if must.count > 1
          AndFilter.new(filters: must).simplify
        elsif must_not.count > 1
          NotFilter.new(filter: AndFilter.new(filters: must_not)).simplify
        else
          must.first.simplify
        end
      end

      def to_search
        { bool: super }
      end
    end
  end
end

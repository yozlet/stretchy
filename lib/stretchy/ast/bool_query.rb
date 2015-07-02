require 'stretchy/ast/base'

module Stretchy
  module AST
    class BoolQuery < Base

      attribute :must,      Array[Base], default: []
      attribute :must_not,  Array[Base], default: []
      attribute :should,    Array[Base], default: []

      validations do
        rule :must,     type: {classes: Base, array: true}
        rule :must_not, type: {classes: Base, array: true}
        rule :should,   type: {classes: Base, array: true}
      end

      def simplify
        return self if should.any? || must_not.any? || must.count > 1
        must.first.simplify
      end

      def to_search
        {
          bool: super
        }
      end

    end
  end
end

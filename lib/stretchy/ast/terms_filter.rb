require 'stretchy/ast/base'

module Stretchy
  module AST
    class TermsFilter < Base

      attribute :field
      attribute :terms

      validations do
        rule :field, field: { required: true }
        rule :terms, type: {classes: [Numeric, Time, String, Symbol, TrueClass, FalseClass], array: true}
        rule :terms, :not_empty
      end

      def after_initialize(options = {})
        @terms = Array(options[:terms])
      end

      def to_search
        {
          terms: {
            @field => @terms
          }
        }
      end
    end
  end
end

require 'stretchy/filters/base'

module Stretchy
  module Filters
    class TermsFilter < Base

      contract field: {type: :field, required: true},
              values: {type: Array,  required: true}

      def initialize(field_or_opts = {}, terms = [])
        if field_or_opts.is_a?(Hash)
          @terms = field_or_opts
        else
          @terms = { field_or_opts => Array(terms) }
        end
        validate_terms!
      end

      def validate_terms!
        exc = Stretchy::Errors::ContractError.new("Terms cannot be blank")
        raise exc if @terms.none? || @terms.any? do |field, terms|
          terms.none?
        end
      end

      def to_search
        {
          terms: @terms
        }
      end
    end
  end
end

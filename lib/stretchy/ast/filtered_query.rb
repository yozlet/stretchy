require 'stretchy/ast/base'
require 'stretchy/ast/bool_query'
require 'stretchy/ast/bool_filter'

module Stretchy
  module AST
    class FilteredQuery < Base

      attribute :query,  Base, default: BoolQuery.new
      attribute :filter, Base, default: BoolFilter.new

      validations do
        rule :query,  type: {classes: Base}
        rule :filter, type: {classes: Base}
      end

      def after_initialize(options = {})
        require_one! :query, :filter
      end

      def to_search
        { filtered: hash_to_search(json_attributes) }
      end
    end
  end
end

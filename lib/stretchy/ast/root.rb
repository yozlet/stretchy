require 'stretchy/ast/base'
require 'stretchy/ast/function_score_query'

module Stretchy
  module AST
    class Root < Base

      attribute :index,           String
      attribute :type,            String
      attribute :from,            Integer
      attribute :size,            Integer
      attribute :fields,          Array
      attribute :aggs,            Hash
      attribute :query,           Base,    default: FunctionScoreQuery.new

      validations do
        rule :index, required: true
        rule :type, required: true
      end

      def after_initialize(options = {})
        @index  ||= Stretchy.index_name
      end

    end
  end
end

require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class BoolQuery < Base

      attribute :must,      Array[Base], default: []
      attribute :must_not,  Array[Base], default: []
      attribute :should,    Array[Base], default: []

      validations do
        rule :must,     type: {classes: Base, array: true}
        rule :must_not, type: {classes: Base, array: true}
        rule :should,   type: {classes: Base, array: true}
      end

      def to_search
        json = {}
        json[:must]     = @must.map(&:to_search)      if @must.any?
        json[:must_not] = @must_not.map(&:to_search)  if @must_not.any?
        json[:should]   = @should.map(&:to_search)    if @should.any?
        { bool: json }
      end

      def add_query(node, options = {})
        case options[:context]
        when :must
          @must << node
        when :must_not
          @must_not << node
        when :should
          @should << node
        when :should_not
          convert_should.add_query(node, must_not: true)
        end
        self
      end

      def convert_should
        bool_should = @should.find {|query| query.is_a?(BoolQuery) }
        unless bool_should
          bool_should = self.class.new(must: @should)
          @should = [bool_should]
        end
        bool_should
      end

    end
  end
end

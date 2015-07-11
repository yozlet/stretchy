require 'stretchy/nodes/base'

module Stretchy
  module Nodes
    class BoolQuery < Base

      attribute :must,      Array[Base]
      attribute :must_not,  Array[Base]
      attribute :should,    Array[Base]

      validations do
        rule :must,     type: {classes: Base, array: true}
        rule :must_not, type: {classes: Base, array: true}
        rule :should,   type: {classes: Base, array: true}
      end

      def after_initialize(options = {})
        require_one! :must, :must_not, :should
      end

      def to_search
        json = {}
        json[:must]     = @must.map(&:to_search)      if @must.any?
        json[:must_not] = @must_not.map(&:to_search)  if @must_not.any?
        json[:should]   = @should.map(&:to_search)    if @should.any?
        { bool: json }
      end

    end
  end
end

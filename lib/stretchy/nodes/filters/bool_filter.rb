require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters
      class BoolFilter < Base

        attribute :must, Array[Base]
        attribute :must_not, Array[Base]
        attribute :should, Array[Base]

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
      end
    end
  end
end

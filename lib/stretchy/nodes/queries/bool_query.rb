require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Queries
      class BoolQuery < Base

        attribute :must,      Array
        attribute :must_not,  Array
        attribute :should,    Array

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

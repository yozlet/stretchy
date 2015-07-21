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

        def add_query(node, options = {})
          if options[:inverse] && options[:should]
            bool_should.add_query(node, options.merge(should: nil))
          elsif options[:should]
            append_should(node, options)
          elsif options[:inverse]
            @must_not << node
          else
            @must << node
          end
          self
        end

        private
          def bool_should
            bool_should!
            should.first
          end

          def bool_should!
            @should = [self.class.new(must: should)] unless bool_should?
          end

          def bool_should?
            should.count == 1 &&
            should.first.respond_to?(:add_query)
          end

          def append_should(node, options)
            if bool_should?
              bool_should.add_query(node, options.merge(should: nil))
            else
              @should << node
            end
          end

      end
    end
  end
end

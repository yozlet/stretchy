module Stretchy
  module Filters
    class BoolFilter < Base

      contract must: {type: Base, array: true},
           must_not: {type: Base, array: true},
             should: {type: Base, array: true}

      def initialize(must:, must_not:, should: nil)
        @must     = Array(must)
        @must_not = Array(must_not)
        @should   = Array(should)
        validate!
      end

      def to_search
        json = {}
        json[:must]     = @must.map(&:to_search)      if @must
        json[:must_not] = @must_not.map(&:to_search)  if @must_not
        json[:should]   = @should.map(&:to_search)    if @should
        { bool: json }
      end
    end
  end
end

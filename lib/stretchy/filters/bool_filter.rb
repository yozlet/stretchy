module Stretchy
  module Filters
    class BoolFilter < Base

      contract must: {type: Base, array: true},
           must_not: {type: Base, array: true},
             should: {type: Base, array: true}

      def initialize(options = {})
        @must     = Array(options[:must])
        @must_not = Array(options[:must_not])
        @should   = Array(options[:should])
        validate!
        require_one(must: @must, must_not: @must_not, should: @should)
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

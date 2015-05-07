require 'stretchy/queries/base'

module Stretchy
  module Queries
    class MatchAllQuery < Base

      def initialize
      end
      
      def to_search
        { match_all: {} }
      end
    end
  end
end

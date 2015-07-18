require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Queries
      class MatchAllQuery < Base

        def to_search
          { match_all: {} }
        end
      end
    end
  end
end

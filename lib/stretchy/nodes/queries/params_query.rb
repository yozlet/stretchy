require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Queries
      class ParamsQuery < Base

        attribute :params, Hash

        validations do
          rule :params, :required
        end

        def initialize(params)
          @params = params
        end

        alias :to_search :params

      end
    end
  end
end

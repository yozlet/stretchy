require 'stretchy/nodes/filters/base'

module Stretchy
  module Nodes
    module Filters

      # This class allows using arbitrary JSON as a filter.
      # This way, users can make use of elasticsearch features
      # not yet supported by Stretchy

      class ParamsFilter < Base

        attribute :params, Hash

        validations do
          rule :params, :required
        end

        def initialize(params)
          @params = params
          validate!
        end

        alias :to_search :params

      end
    end
  end
end

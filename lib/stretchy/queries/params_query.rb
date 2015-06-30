require 'stretchy/queries/base'

module Stretchy
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

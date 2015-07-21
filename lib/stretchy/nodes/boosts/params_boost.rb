require 'stretchy/boosts/base'

module Stretchy
  module Boosts
    class ParamsBoost < Base

      attribute :params, Hash

      validations do
        rule params: :required
      end

      def initialize(params)
        @params = params
        validate!
      end

      alias :to_search, :params

    end
  end
end

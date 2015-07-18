require 'stretchy/nodes/boosts/base'

module Stretchy
  module Nodes
    module Boosts
      # randomizes order (somewhat) consistently per-user
      # http://www.elastic.co/guide/en/elasticsearch/guide/current/random-scoring.html
      class RandomBoost < Base

        attribute :seed,    Numeric
        attribute :weight,  Numeric, default: DEFAULT_WEIGHT

        validations do
          rule :seed,   type: {classes: Numeric, required: true}
          rule :weight, type: {classes: Numeric, required: true}
        end

        def to_search
          {
            random_score: {
              seed: @seed
            },
            weight: @weight
          }
        end

      end
    end
  end
end

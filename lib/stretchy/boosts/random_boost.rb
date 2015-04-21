module Stretchy
  module Boosts
    class RandomBoost < Base

      DEFAULT_WEIGHT = 1.2

      contract seed: {type: Numeric},
             weight: {type: Numeric}

      # randomizes order (somewhat) consistently per-user
      # http://www.elastic.co/guide/en/elasticsearch/guide/current/random-scoring.html

      def initialize(seed, weight = DEFAULT_WEIGHT)
        @seed   = seed
        @weight = weight
        validate!
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

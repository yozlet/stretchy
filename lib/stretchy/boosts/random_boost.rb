module Stretchy
  module Boosts
    class RandomBoost

      DEFAULT_WEIGHT = 1.2

      # randomizes order (somewhat) consistently per-user
      # http://www.elastic.co/guide/en/elasticsearch/guide/current/random-scoring.html

      def initialize(seed, weight = DEFAULT_WEIGHT)
        @seed   = seed
        @weight = weight
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

module Stretchy
  module Boosts
    class RandomBoost

      # randomizes order (somewhat) consistently per-user
      # http://www.elastic.co/guide/en/elasticsearch/guide/current/random-scoring.html

      def initialize(seed, weight = 1)
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

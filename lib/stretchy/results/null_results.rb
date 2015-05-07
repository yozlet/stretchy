require 'stretchy/results/base'

module Stretchy
  module Results
    class NullResults < Base
      # use this class when you don't want to actually run
      # a search, or catch an exception or something

      def response
        @response ||= {
          'took'      => 0,
          'timed_out' => false,
          '_shards'   => {},
          'hits'      => {
            'total'     => 0,
            'max_score' => 0,
            'hits'      => []
          }
        }
      end

    end
  end
end
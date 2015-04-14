module Search
  class NullQuery
    def initialize(options = {})
    end

    def response
      {}
    end

    def id_response
      {}
    end

    def results
      []
    end

    def ids
      []
    end

    def shards
      []
    end

    def total
      0
    end
  end
end

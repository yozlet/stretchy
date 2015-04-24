module Stretchy
  module Results
    class Base

      def initialize(request_json, options = {})
        @request  = request_json
        @index    = options[:index]
        @type     = options[:type]
      end

      def response
        @response ||= Stretchy.search(type: @type, body: request_json)
      end

      def ids
        @ids ||= response['hits']['hits'].map{|h| h['_id'] =~ /\d+(\.\d+)?/ ? h['_id'].to_i : h['_id'] }
      end

      def hits
        @hits ||= response['hits']['hits'].map do |hit|
          merge_fields = hit.reject{|field, _| field == '_source' }
          hit['_source'].merge(merge_fields)
        end
      end
      alias :results :hits

      def took
        @took ||= response['took']
      end

      def shards
        @shards ||= response['_shards']
      end

      def total
        @total ||= response['hits']['total']
      end

      def max_score
        @max_score ||= response['hits']['max_score']
      end

    end
  end
end
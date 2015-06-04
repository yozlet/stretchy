module Stretchy
  module Results
    class Base

      extend Forwardable

      attr_reader :base, :index_name

      delegate [:type, :current_page, :fields, :offset, :limit,
                :aggregations] => :base

      def initialize(base)
        @base       = base
        @index_name = base.index || Stretchy.index_name
      end

      alias :per_page :limit
      alias :limit_value :limit

      def total_pages
        [(total.to_f / limit).ceil, 1].max
      end

      def body
        return @body if @body
        @body        = {query: base.to_search}
        @body[:aggs] = base.aggregate_builder if base.aggregate_builder.any?
        @body
      end

      def request
        return @request if @request
        @request = {
          type: type, 
          body: body,
          from: offset,
          size: limit
        }
        @request[:fields]  = fields   if fields
        @request[:explain] = true     if base.explain
        @request
      end

      def response
        @response ||= Stretchy.search(request)
      end

      def ids
        @ids ||= response['hits']['hits'].map{|h| h['_id'] =~ /\d+(\.\d+)?/ ? h['_id'].to_i : h['_id'] }
      end

      def hits
        @hits ||= response['hits']['hits'].map do |hit|
          merge_fields = hit.reject{|field, _| ['_source', 'fields'].include?(field) }
          
          source_fields = {}
          if hit['fields']
            source_fields = Stretchy::Utils::DotHandler.convert_from_dotted_keys(hit['fields'])
          elsif hit['_source']
            source_fields = hit['_source']
          end
          
          source_fields.merge(merge_fields)
        end
      end
      alias :results :hits

      def scores
        @scores ||= Hash[response['hits']['hits'].map do |hit|
          [hit['_id'], hit['_score']]
        end]
      end

      def explanations
        @scores ||= Hash[response['hits']['hits'].map do |hit|
          [hit['_id'], hit['_explanation']]
        end]
      end

      def aggregations
        @aggregations ||= response['aggregations']
      end

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
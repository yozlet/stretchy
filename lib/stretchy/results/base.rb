module Stretchy
  module Results
    class Base

      extend Forwardable

      attr_reader :clause, :index_name

      delegate [:type, :current_page, :limit_value] => :clause

      def initialize(clause)
        @clause     = clause
        @index_name = clause.index_name || Stretchy.index_name
      end

      def limit
        clause.get_limit
      end
      alias :per_page :limit
      alias :limit_value :limit

      def fields
        clause.get_fields
      end

      def offset
        clause.get_offset
      end

      def page
        clause.get_page
      end

      def total_pages
        [(total.to_f / limit).ceil, 1].max
      end

      def request
        return @request if @request
        @request        = {query: clause.to_search}
        @request[:aggs] = clause.get_aggregations if clause.get_aggregations.any?
        @request
      end

      def response
        params = {
          type: type, 
          body: request,
          from: offset,
          size: limit
        }
        params[:fields]  = fields   if fields
        params[:explain] = true     if clause.get_explain
        @response ||= Stretchy.search(params)
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
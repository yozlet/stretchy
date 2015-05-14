module Stretchy
  module Utils
    module ClientActions

      def self.extended(base)
        unless base.respond_to?(:client) && base.respond_to?(:index_name)
          raise "ClientActions requires methods 'client' and 'index_name'"
        end
      end

      # used for ensuring a consistent index in specs
      def refresh
        Stretchy.log("Refreshing index: #{index_name}")
        client.indices.refresh index: index_name
      end

      def count
        Stretchy.log("Counting all documents in index: #{index_name}")
        client.cat.count(index: index_name).split(' ')[2].to_i
      end

      def query(*args, &block)
        Stretchy::Clauses::Base.new(*args, &block)
      end

      def search(options = {})
        params = {}
        params[:index]  = options[:index] || index_name
        params[:fields] = Array(options[:fields]) if options[:fields]
        
        [:type, :body, :from, :size, :explain].each do |field|
          params[field] = options[field] if options[field]
        end

        Stretchy.log("Querying Elastic:", params)
        response = client.search(params)
        Stretchy.log("Received response:", response)
        response
      end

      def index(options = {})
        index = options[:index] || index_name
        type  = options[:type]
        body  = options[:body]
        id    = options[:id] || options['id'] || body['id'] || body['_id'] || body[:id] || body[:_id]
        params = {
          index:  index,
          type:   type,
          id:     id,
          body:   body
        }
        Stretchy.log("Indexing document:", params)
        response = client.index(params)
        Stretchy.log("Received response:", response)
        response
      end

      def bulk(options = {})
        type      = options[:type]
        documents = options[:documents]
        requests  = documents.flat_map do |document|
          id = document['id'] || document['_id'] || document[:id] || document[:_id]
          [
            { index: { '_index' => index_name, '_type' => type, '_id' => id } },
            document
          ]
        end
        Stretchy.log("Bulk indexing documents:", {body: requests})
        response = client.bulk body: requests
        Stretchy.log("Received response:", response)
      end

      def exists(_index_name = index_name)
        Stretchy.log("Checking index existence for: #{_index_name}")
        client.indices.exists(index: _index_name)
      end
      alias :exists? :exists

      def delete(_index_name = index_name)
        Stretchy.log("Deleting index: #{_index_name}")
        client.indices.delete(index: _index_name) if exists?(_index_name)
      end

      def create(_index_name = index_name)
        Stretchy.log("Creating index: #{_index_name}")
        client.indices.create(index: _index_name) unless exists?(_index_name)
      end

      def mapping(_index_name, _type, _body)
        Stretchy.log("Putting mapping:", {index_name: _index_name, type: _type, body: _body})
        client.indices.put_mapping(index: _index_name, type: _type, body: _body)
      end

    end
  end
end
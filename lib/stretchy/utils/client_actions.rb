module Stretchy
  module Utils
    module ClientActions

      def self.extended(base)
        unless base.respond_to?(:client) && base.respond_to?(:index_name)
          raise "ClientActions requires methods 'client' and 'index_name'"
        end
      end

      # used for ensuring a concistent index in specs
      def refresh
        client.indices.refresh index: index_name
      end

      def count
        client.cat.count(index: index_name).split(' ')[2].to_i
      end

      def query(*args, &block)
        Stretchy::Clauses::Base.new(*args, &block)
      end

      def search(options = {})
        params = {}
        params[:index]  = options[:index] || index_name
        params[:type]   = options[:type]
        params[:fields] = Array(options[:fields]) if options[:fields]
        params[:body]   = options[:body]

        client.search(params)
      end

      def index(options = {})
        index = options[:index] || index_name
        type  = options[:type]
        body  = options[:body]
        id    = options[:id] || options['id'] || body['id'] || body['_id'] || body[:id] || body[:_id]
        client.index(index: index, type: type, id: id, body: body)
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
        client.bulk body: requests
      end

      def exists(_index_name = index_name)
        client.indices.exists(index: _index_name)
      end
      alias :exists? :exists

      def delete(_index_name = index_name)
        client.indices.delete(index: _index_name) if exists?(_index_name)
      end

      def create(_index_name = index_name)
        client.indices.create(index: _index_name) unless exists?(_index_name)
      end

      def mapping(_index_name, _type, _body)
        client.indices.put_mapping(index: _index_name, type: _type, body: _body)
      end

    end
  end
end
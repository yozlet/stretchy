module Stretchy
  module Configuration
    
    attr_accessor :index_name, :logger, :url, :adapter, :client

    def self.extended(base)
      base.set_default_configuration
    end

    def configure
      yield self
    end

    def set_default_configuration
      self.index_name = 'myapp'
      self.adapter =    :excon
      self.url =        ENV['ELASTICSEARCH_URL']
    end

    def client_options
      Hash[
        index_name: index_name,
        log:        !!logger,
        logger:     logger,
        adapter:    adapter,
        url:        url
      ]
    end

    def client(options = {})
      return @client if @client

      @client = Elasticsearch::Client.new(default_opts.merge(options))
    end

    # used for ensuring a concistent index in specs
    def refresh
      client.indices.refresh index: INDEX
    end

    def count
      client.cat.count(index: INDEX).split(' ')[2].to_i
    end

    def search(type:, body:, fields: nil)
      options = { index: index_name, type: type, body: body }
      options[:fields] = fields if fields.is_a?(Array)

      client.search(options)
    end

    def index(type:, body:, id: nil)
      id ||= body['id'] || body['_id'] || body[:id] || body[:_id]
      client.index(index: index_name, type: type, id: id, body: body)
    end

    def bulk(type:, documents:)
      requests = documents.flat_map do |document|
        id = document['id'] || document['_id'] || document[:id] || document[:_id]
        [
          { index: { '_index' => index_name, '_type' => type, '_id' => id } },
          document
        ]
      end
      client.bulk body: requests
    end
  end
end
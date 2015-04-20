module Stretchy
  module Utils
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
        @client ||= Elasticsearch::Client.new(client_options.merge(options))
      end
    end
  end
end
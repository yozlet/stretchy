module Stretchy
  module Utils
    module Configuration
      
      attr_accessor :index_name, :logger, :log_level, :log_color, :url, :adapter, :client

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
        self.log_level =  :silence
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

      def connect(options = {})
        @client = Elasticsearch::Client.new(client_options.merge(options))
      end

      def client(options = {})
        @client || connect(options)
      end

      def log_handler
        @log_handler ||= Stretchy::Utils::Logger.new(logger, log_level, log_color)
      end

      def log(*args)
        args.each {|arg| log_handler.log(arg) }
      end
    end
  end
end
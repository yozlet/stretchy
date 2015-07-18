require 'json'
require 'logger'
require 'forwardable'
require 'excon'
require 'elasticsearch'
require 'virtus'
require 'validation'

require 'stretchy_validations'
require 'stretchy/errors'
require 'stretchy/nodes'
require 'stretchy/results'
require 'stretchy/utils'
require 'stretchy/version'

# {include:file:README.md}

module Stretchy
  extend Stretchy::Utils::Configuration

  module_function

    # used for ensuring a consistent index in specs
    def refresh(_index = nil)
      _index ||= index_name
      Stretchy.log("Refreshing index: #{_index}")
      client.indices.refresh index: _index
    end

    def count(_index = nil)
      _index ||= index_name
      Stretchy.log("Counting all documents in index: #{_index}")
      client.cat.count(index: _index).split(' ')[2].to_i
    end

    def query(*args, &block)
      Stretchy::Clauses::Base.new(*args, &block)
    end

    def search(options = {})
      options[:index] ||= index_name
      Stretchy.log("Querying Elastic:", options)
      response = client.search(options)
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

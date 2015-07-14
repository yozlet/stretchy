require 'stretchy/utils/validation'
require 'stretchy/nodes/root'

module Stretchy
  module Api
    class Base

      extend Forwardable
      include Utils::Validation

      delegate [:to_search] => :root

      attribute :root,    Nodes::Base, default: Nodes::Root.new
      attribute :current, Nodes::Base

      def after_initialize(options = {})
        root.index = options[:indices] || Array(options[:index])
        root.type  = options[:types]   || Array(options[:type])
        @current   = root
      end

      def match(string_or_params, options = {})
        hashify_params(string_or_params).each do |field, query|
          @current = current.add(
            Nodes::MatchQuery.new(field: field, string: query.split(' '), parent: current)
          )
        end
        self
      end

      def where(params = {}, options = {})
        params.each do |field, terms|
          @current = current.add(terms_node(field, terms))
        end
        self
      end

      def results
        @results ||= Stretchy.search(to_search)['hits']['hits']
      end

      def result_ids
        @result_ids ||= results.map{|r| (r['id'] || r['_id']).to_i }
      end

      private

        def hashify_params(string_or_hash)
          if string_or_hash.is_a?(Hash)
            string_or_hash
          else
            { '_all' => string_or_hash }
          end
        end

        def terms_node(field, val)
          case val
          when nil
            raise 'Nil terms not supported yet'
          when Hash
            raise 'Hash terms not supported yet'
          when Range
            raise 'Range terms not supported yet'
          else
            Nodes::TermsFilter.new(field: field, terms: [val])
          end
        end

    end
  end
end

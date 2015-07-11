require 'stretchy/nodes/base'

module Stretchy
  module Api
    class Base

      include Utils::Validation

      attribute :root,    Nodes::Base, default: Nodes::Base.new
      attribute :current, Nodes::Base

      def after_initialize(options = {})
        @current = root
      end

      def match(string_or_params, options = {})
        hashify_params(string_or_params).each do |field, query|
          current.add_query(
            Nodes::MatchQuery.new(field: field, string: query)
          )
        end
        self
      end

      private

        def hashify_params(string_or_hash)
          if string_or_hash.is_a?(Hash)
            string_or_hash
          else
            { '_all' => string_or_hash }
          end
        end

    end
  end
end

require 'stretchy/utils/poro'

module Stretchy
  module Nodes
    class Base

      include Utils::Poro

      def replace_node(original, replacement)
        attributes.find do |field, value|
          if value == original
            send("#{field}=", replacement)
          elsif value.is_a?(Hash)
            replace_node_in_hash(original, replacement, value)
          elsif value.respond_to?(:each)
            replace_node_in_collection(original, replacement, value)
          end
        end
      end

      protected

        def replace_node_in_hash(original, replacement, hash)
          hash.find do |key, value|
            if value == original
              hash[key] = replacement
            elsif value.is_a?(Hash)
              replace_node_in_hash(original, replacement, value)
            elsif value.respond_to?(:find)
              replace_node_in_collection(original, replacement, value)
            elsif value.respond_to?(:attributes)
              replace_node(original, replacement)
            end
          end
        end

        def replace_node_in_collection(original, replacement, collection)
          collection.find do |value|
            if value == original
              index = collection.index(original)
              collection[index] = replacement
            elsif value.is_a?(Hash)
              replace_node_in_hash(original, replacement, value)
            elsif value.respond_to?(:find)
              replace_node_in_collection(original, replacement, value)
            elsif value.respond_to?(:attributes)
              replace_node(original, replacement, value)
            end
          end
        end
    end
  end
end

module Stretchy
  module Utils
    module DotHandler

      module_function

      def self.convert_from_dotted_keys(hash)
        new_hash = {}

        hash.each do |key, value|
          h = new_hash

          parts = key.to_s.split('.')
          while parts.length > 0
            new_key = parts[0]
            rest = parts[1..-1]

            if not h.instance_of? Hash
              raise ArgumentError, "Trying to set key #{new_key} to value #{value} on a non hash #{h}\n"
            end

            if rest.length == 0
              if h[new_key].instance_of? Hash
                raise ArgumentError, "Replacing a hash with a scalar. key #{new_key}, value #{value}, current value #{h[new_key]}\n"
              end

              h.store(new_key, value)
              break
            end

            if h[new_key].nil?
              h[new_key] = {}
            end

            h = h[new_key]
            parts = rest
          end
        end

        new_hash
      end
    end
  end
end
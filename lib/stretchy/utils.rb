module Stretchy
  module Utils

    module_function

    def deep_merge(hash, other_hash, &block)
      deep_merge! hash.dup, other_hash, &block
    end

    def deep_merge!(hash, other_hash, &block)
      other_hash.each_pair do |current_key, other_value|
        this_value = hash[current_key]

        hash[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
          deep_merge(this_value, other_value, &block)
        elsif this_value.is_a?(Array) && other_value.is_a?(Array)
          (this_value + other_value).uniq
        else
          if block_given? && hash.key?(current_key)
            block.call(current_key, this_value, other_value)
          else
            other_value
          end
        end
      end

      hash
    end

    def is_empty?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

  end
end

require 'stretchy/utils/validation'
require 'stretchy/utils/colorize'
require 'stretchy/utils/logger'
require 'stretchy/utils/dot_handler'
require 'stretchy/utils/configuration'
require 'stretchy/utils/client_actions'

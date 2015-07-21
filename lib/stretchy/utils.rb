module Stretchy
  module Utils

    module_function

    def is_empty?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    def present?(value)
      !is_empty?(value)
    end

    def slice(hash, *keys)
      hash.select {|key, val|
        keys.include?(key)
      }
    end
  end
end

require 'stretchy/utils/colorize'
require 'stretchy/utils/configuration'
require 'stretchy/utils/dot_handler'
require 'stretchy/utils/logger'
require 'stretchy/utils/poro'

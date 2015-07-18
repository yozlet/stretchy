require 'stretchy/nodes/types/base'

module Stretchy
  module Nodes
    module Types
      class Range < Base

        attribute :min
        attribute :max
        attribute :exclusive_min
        attribute :exclusive_max

        validations do
          rule :min, type: {classes: [Numeric, Date, Time] }
          rule :max, type: {classes: [Numeric, Date, Time] }
          rule :exclusive_min, inclusion: {in: [true, false]}
          rule :exclusive_max, inclusion: {in: [true, false]}
        end

        def initialize(opts_or_range = {}, options = {})

          case opts_or_range
          when ::Range
            @min = opts_or_range.min
            @max = opts_or_range.max
            @exclusive_min = !!(options[:exclusive_min] || options[:exclusive])
            @exclusive_max = !!(options[:exclusive_max] || options[:exclusive])
            @inverse       = !!options[:inverse]
            @should        = !!options[:should]
          when ::Hash
            opts = options.merge(opts_or_range)
            @min = opts[:min]
            @max = opts[:max]
            @exclusive_min = !!(opts[:exclusive_min] || opts[:exclusive])
            @exclusive_max = !!(opts[:exclusive_max] || opts[:exclusive])
            @inverse       = !!opts[:inverse]
            @should        = !!opts[:should]
          when Range
            @min = opts_or_range.min
            @max = opts_or_range.max
            @exclusive_min = opts_or_range.exclusive_min
            @exclusive_max = opts_or_range.exclusive_max
          else
            raise Stretchy::Errors::ContractError.new("Ranges must be a range or a hash - found #{options.class.name}")
          end

          require_one! :min, :max
          validate!
        end

        def empty?
          !(@min || @max)
        end

        def to_search
          json = {}
          if @exclusive_min && @min
            json[:gt] = @min
          elsif @min
            json[:gte] = @min
          end

          if @exclusive_max && @max
            json[:lt] = @max
          elsif @max
            json[:lte] = @max
          end
          json
        end

      end
    end
  end
end

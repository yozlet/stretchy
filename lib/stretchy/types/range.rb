module Stretchy
  module Types
    class Range < Base

      attr_reader :min, :max, :exclusive_min, :exclusive_max

      contract    min: { type: [Numeric, Date, Time] },
                  max: { type: [Numeric, Date, Time] },
        exclusive_min: { in: [true, false] },
        exclusive_max: { in: [true, false] }

      def initialize(opts_or_range = {}, options = {})

        case opts_or_range
        when ::Range
          @min = opts_or_range.min
          @max = opts_or_range.max
          @exclusive_min = !!(options[:exclusive_min] || options[:exclusive])
          @exclusive_max = !!(options[:exclusive_max] || options[:exclusive])
        when ::Hash
          opts = options.merge(opts_or_range)
          @min = opts[:min]
          @max = opts[:max]
          @exclusive_min = !!(opts[:exclusive_min] || opts[:exclusive])
          @exclusive_max = !!(opts[:exclusive_max] || opts[:exclusive])
        else
          raise Stretchy::Errors::ContractError.new("Ranges must be a range or a hash - found #{options.class.name}")
        end

        require_one min: @min, max: @max
        validate!
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
require 'stretchy/ast/base'

module Stretchy
  module AST
    class RangeNode < Base

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

      def self.from_options(options = {})
        case options
        when self
          options
        when Range
          from_range_param(options)
        when Hash
          self.new(options)
        else
          raise Errors::ValidationError.new(
            options: :type
          )
        end
      end

      def self.from_range_param(param)
        self.new(min: param.min, max: param.max)
      end

      def after_initialize(options = {})
        require_one! :min, :max
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

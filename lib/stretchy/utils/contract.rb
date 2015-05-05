module Stretchy
  module Utils
    module Contract

      ASSERTIONS = [:type, :responds_to, :in, :matches, :required]
      DISTANCE_FORMAT = /^(\d+)(km|mi)$/
      DECAY_FUNCTIONS = [:gauss, :linear, :exp]

      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      def validate!
        self.class.contracts.each do |name, options|
          value = instance_variable_get("@#{name}")
          next if value.nil? && !options[:required]
          
          if options[:array]
            self.class.assert_type(name, value, type: Array)
          end

          ASSERTIONS.each do |assertion|
            assertion_method = "assert_#{assertion}"
            if options[:array]
              value.each {|v| self.class.send(assertion_method, name, v, options) } unless options[assertion].nil?
            else
              self.class.send(assertion_method, name, value, options) unless options[assertion].nil?
            end
          end
        end
      end

      def require_one(options = {})
        if options.values.all?{|v| self.class.is_empty?(v) }
          raise Stretchy::Errors::ContractError.new("One of #{options.keys.join(', ')} must be present")
        end
      end

      module ClassMethods

        attr_reader :contracts

        def is_empty?(value)
          value.nil? ||
          (value.respond_to?(:any?) && !value.any?) ||
          (value.respond_to?(:length) && value.length == 0)
        end

        def contract(var, options = {})
          @contracts ||= {}
          if var.is_a?(Hash)
            var.each {|k,v| @contracts[k] = v }
          else
            @contracts[var] = options
          end
        end

        def fail_assertion(msg)
          raise Stretchy::Errors::ContractError.new(msg)
        end

        def assert_required(name, value, options)
          msg = "Expected to have param #{name}, but got nil"
          fail_assertion(msg) if msg.nil?
        end

        def assert_type(name, value, options)
          type = options[:type]
          case type
          when :distance
            msg = "Expected #{name} to be a distance measure, but #{value} is not a valid distance"
            fail_assertion(msg) unless String(value).match(DISTANCE_FORMAT)
          when :lat
            msg = "Expected #{name} to be between 90 and -90, but was #{value}"
            value = Float(value) rescue nil
            fail_assertion(msg) unless value && value <= 90 && value >= -90
          when :lng 
            msg = "Expected #{name} to be between 180 and -180, but was #{value}"
            value = Float(value) rescue nil
            fail_assertion(msg) unless value && value.to_f <= 180 && value.to_f >= -180
          when :field
            msg = "Expected #{name} to be a string, symbol, or number, but got #{value.class.name}"
            fail_assertion(msg) unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(Numeric)

            msg = "Expected #{name} to be a string, symbol, or number, but was blank"
            fail_assertion(msg) if value.is_a?(String) && value.empty?
          when :decay
            msg = "Expected #{name} to be one of #{DECAY_FUNCTIONS.join(', ')}, but got #{value}"
            fail_assertion(msg) unless DECAY_FUNCTIONS.any?{|f| f == value || f.to_s == value }
          when Array
            msg = "Expected #{name} to be one of #{type.map{|t| t.name}}, but got #{value.class.name}"
            fail_assertion(msg) unless type.any?{|t| value.is_a?(t)}
          else
            msg = "Expected #{name} to be of type #{type}, but found #{value.class.name}"
            fail_assertion(msg) unless value.is_a?(type)
          end
        end

        def assert_responds_to(name, value, options)
          method = options[:responds_to]
          msg = "Expected #{name} to respond_to #{method}, but #{value.class.name} does not"
          fail_assertion(msg) unless value.respond_to?(method)
        end

        def assert_in(name, value, options)
          collection = options[:in]
          msg = "Expected #{name} to be one of #{collection}, but got #{value}"
          fail_assertion(msg) unless collection.include?(value)
        end

        def assert_matches(name, value, options)
          matcher = options[:matches]
          msg = "Expected #{name} to match #{matcher}, but #{value} does not"
          fail_assertion(msg) unless matcher.match(value)
        end
      end
    end
  end
end
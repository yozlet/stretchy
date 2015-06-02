module Stretchy
  module Utils
    module Validation

      def self.included(base)
        base.send(:include, Virtus.model)
        base.extend(ClassMethods)
      end

      def initialize(attributes = nil)
        self.class.attribute_set.set(self, attributes) if attributes
        set_default_attributes
        validate!
        after_initialize if respond_to?(:after_initialize)
      end

      def validator
        @validator ||= self.class.validator.new(self)
      end

      def validate!
        raise Errors::ValidationError.new(errors) unless valid?
      end

      def require_one!(*attrs)
        rule = ::Validation::Rule::Required.new
        errors = {}
        unless attrs.any? {|a| rule.valid_value?( send(a) ) }
          raise Errors::ValidationError.new(
            attrs.join(', ') => {
              rule: :require_one_of
            }
          )
        end
        true
      end

      def require_only_one!(*attrs)
        rule = ::Validation::Rule::Required.new
        errors = {}
        if attrs.select {|a| rule.valid_value?( send(a) ) }.count > 1
          raise Errors::ValidationError.new(
            attrs.join(', ') => {
              rule: :require_only_one
            }
          )
        end
        true
      end

      def valid?
        validator.valid?
      end

      def errors
        validator.errors
      end

      module ClassMethods

        def validations(&block)
          @validator = Class.new(::Validation::Validator) do
            include ::Validation

            class_exec(&block)
          end
        end

        def validator
          @validator
        end

      end

    end
  end
end
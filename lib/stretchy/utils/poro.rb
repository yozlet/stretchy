module Stretchy
  module Utils
    module Poro

      def self.included(base)
        base.send(:include, Virtus.model)
        base.class_exec { include Constructor }
        base.extend(ClassMethods)
        base.extend(Forwardable)
      end

      def validator
        @validator ||= self.class.validator.new(self) if self.class.validator
      end

      def validate!
        raise Errors::ValidationError.new(errors) unless valid?
      end

      def require_one!(*attrs)
        unless attrs.any? {|a| Utils.is_empty?(a) }
          raise Errors::ValidationError.new(
            attrs.join(', ') => {
              rule: :require_one_of
            }
          )
        end
        true
      end

      def require_only_one!(*attrs)
        if attrs.select {|a| Utils.is_empty?(a) }.count > 1
          raise Errors::ValidationError.new(
            attrs.join(', ') => {
              rule: :require_only_one
            }
          )
        end
        true
      end

      def valid?
        validator ? validator.valid? : true
      end

      def errors
        validator ? validator.errors : []
      end

      def json_attributes
        for_json = self.attributes.reject{|key, val| Utils.is_empty?(val) }
        for_json = for_json.map {|key, val| val.respond_to?(&:to_search) ? val.to_search : val }
        Hash[for_json]
      end

      module Constructor

        def initialize(attributes = nil)
          self.class.attribute_set.set(self, attributes) if attributes
          set_default_attributes
          after_initialize(attributes) if respond_to?(:after_initialize)
          validate!
        end

      end

      module ClassMethods

        def validations(&block)
          parent_klass = self
          @validator = Class.new(::Validation::Validator) do
            include ::Validation

            class_exec(&block)

            def parent_klass
              parent_klass
            end

            def to_s
              "#<#{parent_klass}::Validations:#{object_id}>"
            end

            def inspect
              to_s
            end
          end
        end

        def validator
          @validator
        end

      end

    end
  end
end

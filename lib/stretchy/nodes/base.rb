require 'stretchy/utils/validation'

module Stretchy
  module Nodes
    class Base

      include Utils::Validation

      attribute :parent

      validations do
        rule :parent, type: Base
      end

      def to_search
        json = json_attributes.keep_if do |name, obj|
          name != :parent && Utils.present?(obj)
        end

        json = json.map do |name, obj|
          obj.is_a?(self.class) ? [name, obj.to_search] : [name, obj]
        end
        Hash[json]
      end

    end
  end
end

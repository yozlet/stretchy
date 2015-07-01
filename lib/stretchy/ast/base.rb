module Stretchy
  module AST
    class Base

      include Stretchy::Utils::Validation

      def compile
        Hash[json_attributes.map{|k,v| v.is_a?(Base) ? [k, v.compile] : [k,v] }]
      end

    end
  end
end

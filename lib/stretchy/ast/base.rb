module Stretchy
  module AST
    class Base

      include Utils::Validation

      def simplify
        self
      end

      def to_search
        hash_to_search(json_attributes)
      end

      def any?
        json_attributes.any?{|key, val| Utils.present?(val) }
      end

      def empty?
        !any?
      end

      protected

        def hash_to_search(hsh)
          Hash[hsh.map do |key, val|
            case val
            when Hash
              [key, hash_to_search(val)]
            when Array, Enumerable
              [key, array_to_search(val)]
            else
              [key, val_to_search(val)]
            end
          end]
        end

        def array_to_search(arr)
          arr.map{|val| val_to_search(val) }
        end

        def val_to_search(val)
          _val = val.respond_to?(:simplify) ? val.simplify    : val
          _val.respond_to?(:to_search)      ? _val.to_search  : _val
        end

    end
  end
end

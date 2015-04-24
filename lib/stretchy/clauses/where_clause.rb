module Stretchy
  module Clauses
    class WhereClause < Base

      def initialize(base, options = {})
        super(base)
        @where_builder ||= Stretchy::Builders::WhereBuilder.new
        @inverse = options.delete(:inverse)
        add_params(options)
      end

      def range(field, options = {})
        min = max = nil
        
        case options
        when Hash
          min   = options[:min]
          max   = options[:max]
          store = inverse? ? @where_builder.antiranges : @where_builder.ranges
          store[field] = { min: min, max: max }
        when Range
          add_param(field, options)
        end

        self
      end

      def geo(field, options = {})
        add_geo(field, options)
        self
      end

      def not(options = {})
        self.class.new(self, options.merge(inverse: !@inverse))
      end

      private

        def inverse?
          @inverse
        end
        
        def add_params(options = {})
          options.each do |field, param|
            if param.is_a?(Array)
              param.each {|p| add_param(field, p) }
            else
              add_param(field, param)
            end
          end
        end

        def add_geo(field, options = {})
          store = inverse? ? @where_builder.antigeos : @where_builder.geos
          store[field] = options
        end

        def add_param(field, param)
          case param
          when nil
            store = inverse? ? @where_builder.exists : @where_builder.empties
            store += Array(field)
          when String, Symbol
            store = inverse? ? @where_builder.antimatches : @where_builder.matches
            store[field] += Array(param)
          when Range
            store = inverse? ? @where_builder.antiranges : @where_builder.ranges
            store[field] = { min: param.min, max: param.max }
          else
            store = inverse? ? @where_builder.antiterms : @where_builder.terms
            store[field] += Array(param)
          end
        end

    end
  end
end
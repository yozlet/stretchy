module Stretchy
  module Clauses
    class WhereClause < Base

      def self.tmp(options = {})
        self.new(Base.new, options)
      end

      def initialize(base, options = {})
        super(base)
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

      def to_query
        Stretchy::Queries::FilteredQuery.new(
          query:  @match_builder.build,
          filter: @where_builder.build
        )
      end

      private
        
        def add_params(options = {})
          options.each do |field, param|
            # if it is an array, process each param
            # separately - ensures string & symbols
            # always go into .match_builder
            
            if param.is_a?(Array)
              param.each{|p| add_param(field, p) }
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
            if inverse?
              @match_builder.antimatches[field] += Array(param)
            else
              @match_builder.matches[field] += Array(param)
            end
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
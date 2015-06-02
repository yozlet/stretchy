module Stretchy
  module Builders
    class WhereBuilder

      extend Forwardable

      attr_accessor :must, :must_not, :should, :should_not

      def initialize(options = {})
        @must         = FilterBuilder.new
        @must_not     = FilterBuilder.new(inverse: true)
        @should       = FilterBuilder.new(should:  true)
        @should_not   = FilterBuilder.new(inverse: true, should: true)
      end

      def any?
        must.any? || must_not.any? || should.any? || should_not.any?
      end

      def use_bool?
        (must.any? && must_not.any?) || should.any? || should_not.any?
      end

      def add_param(field, param, options = {})
        case param
        when nil
          builder_from_options(options.merge(inverse: !options[:inverse])).add_exists(field)
        when ::Range, Types::Range
          builder_from_options(options).add_range(field, param)
        else
          builder_from_options(options).add_terms(field, param)
        end
      end

      def add_geo(field, distance, options = {})
        if options[:geo_point]
          geo_point = Types::GeoPoint.new(options[:geo_point])
        else
          geo_point = Types::GeoPoint.new(options)
        end
        
        builder_from_options(options).add_geo(field, distance, geo_point)
      end

      def add_range(field, options = {})
        builder_from_options(options).add_range(field, options)
      end

      def to_filter
        if use_bool?
          bool_filter
        elsif must.any?
          and_filter
        elsif must_not.any?
          not_filter
        else
          nil
        end
      end

      private

        def builder_from_options(options = {})
          return must unless options.is_a?(Hash)
          if options[:inverse] && options[:should]
            should_not
          elsif options[:inverse]
            must_not
          elsif options[:should]
            should
          else
            must
          end
        end

        def bool_filter
          Stretchy::Filters::BoolFilter.new(
            must:     must.to_filters,
            must_not: must_not.to_filters,
            should:   build_should
          )
        end

        def and_filter
          filter = nil
          filters = must.to_filters
          if filters.count > 1
            filter = Stretchy::Filters::AndFilter.new(filters)
          else
            filter = filters.first
          end
          filter
        end

        def not_filter
          filter = must_not.to_filters
          filter = Stretchy::Filters::OrFilter.new(filter) if filter.count > 1
          Stretchy::Filters::NotFilter.new(filter)
        end

        def build_should
          if should.any? && should_not.any?
            Stretchy::Filters::BoolFilter.new(
              must:     should.to_filters,
              must_not: should_not.to_filters
            )
          elsif should_not.any?
            filters = should_not.to_filters
            if filters.count > 1
              filters = Stretchy::Filters::OrFilter.new(filters) 
            else
              filters = filters.first
            end
            
            Stretchy::Filters::NotFilter.new(filters)
          else
            filters = should.to_filters
            filters = Stretchy::Filters::AndFilter.new(filters) if filters.count > 1
            filters
          end
        end
      end
  end
end
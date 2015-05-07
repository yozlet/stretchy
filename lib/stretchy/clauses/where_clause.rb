require 'stretchy/clauses/base'

module Stretchy
  module Clauses
    class WhereClause < Base

      def self.tmp(options = {})
        self.new(Base.new, options)
      end

      def initialize(base, options = {})
        super(base)
        @inverse = options.delete(:inverse)
        @should  = options.delete(:should)
        add_params(options)
      end

      def should?
        !!@should
      end

      def range(field, options = {})
        get_storage(:ranges)[field] = Stretchy::Types::Range.new(options)
        self
      end

      def geo(field, options = {})
        get_storage(:geos)[field] = {
          distance:  options[:distance],
          geo_point: Stretchy::Types::GeoPoint.new(options)
        }
        self
      end

      def not(options = {})
        self.class.new(self, options.merge(inverse: true, should: should?))
      end

      def should(options = {})
        self.class.new(self, options.merge(should: true))
      end

      def to_boost(weight = nil)
        weight ||= Stretchy::Boosts::FilterBoost::DEFAULT_WEIGHT
        
        if @match_builder.any? && @where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              Stretchy::Queries::FilteredQuery.new(
                query:  @match_builder.build,
                filter: @where_builder.build
              )
            ),
            weight: weight
          )
        
        elsif @match_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: Stretchy::Filters::QueryFilter.new(
              @match_builder.build
            ),
            weight: weight
          )

        elsif @where_builder.any?
          Stretchy::Boosts::FilterBoost.new(
            filter: @where_builder.build,
            weight: weight
          )
        end
      end

      private

        def get_storage(builder_field, is_inverse = nil)
          is_inverse = inverse? if is_inverse.nil?
          field = builder_field.to_s
          if inverse? || is_inverse
            if should?
              field = "shouldnot#{field}"
            else
              field = "anti#{field}"
            end
          else
            field = "should#{field}" if should?
          end
          
          if field =~ /match/
            @match_builder.send(field)
          else
            @where_builder.send(field)
          end
        end
        
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

        def add_param(field, param)
          case param
          when nil
            get_storage(:exists, true) << field
          when String, Symbol
            get_storage(:matches)[field] += Array(param)
          when Range
            get_storage(:ranges)[field] = Stretchy::Types::Range.new(param)
          else
            get_storage(:terms)[field] += Array(param)
          end
        end

    end
  end
end
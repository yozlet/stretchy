module Stretchy
  module Clauses
    class MatchClause < Base

      def self.tmp(options = {})
        self.new(Base.new, options)
      end

      def initialize(base, opts_or_str = {}, options = {})
        super(base)
        if opts_or_str.is_a?(Hash)
          @inverse     = opts_or_str.delete(:inverse) || options.delete(:inverse)
          @should      = opts_or_str.delete(:should)  || options.delete(:should)
          add_params(options.merge(opts_or_str))
        else
          @inverse     = options.delete(:inverse)
          @should      = options.delete(:should)
          add_params(options.merge('_all' => opts_or_str))
        end
      end

      def not(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(inverse: true, should: should?))
      end

      def should(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(should: true))
      end

      def to_boost(weight = nil)
        weight ||= Stretchy::Boosts::FilterBoost::DEFAULT_WEIGHT
        Stretchy::Boosts::FilterBoost.new(
          filter: Stretchy::Filters::QueryFilter.new(
            @match_builder.build
          ),
          weight: weight
        )
      end

      def should?
        !!@should
      end

      private

        def get_storage
          if inverse?
            if should?
              @match_builder.shouldnotmatches
            else
              @match_builder.antimatches
            end
          else
            if should?
              @match_builder.shouldmatches
            else
              @match_builder.matches
            end
          end
        end

        def add_params(params = {})
          case params
          when Hash
            params.each do |field, params|
              add_param(field, params)
            end
          else
            add_param('_all', params)
          end
        end

        def add_param(field, param)
          get_storage[field] += Array(param)
        end

    end
  end
end
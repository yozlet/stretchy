module Stretchy
  module Clauses
    class MatchClause < Base

      def self.tmp(options = {})
        base        = Base.new
        match_store = Stretchy::Builders::MatchBuilder.new
        self.new(base, options.merge(match_store: match_store))
      end

      def initialize(base, opts_or_str = {}, options = {})
        super(base)
        if opts_or_str.is_a?(Hash)
          @inverse     = opts_or_str.delete(:inverse)     || options.delete(:inverse)
          @match_store = opts_or_str.delete(:match_store) || options.delete(:match_store) || @match_builder
          add_params(options.merge(opts_or_str))
        else
          @inverse     = options.delete(:inverse)
          @match_store = options.delete(:match_store) || @match_builder
          add_params(options.merge('_all' => opts_or_str))
        end
      end

      def not(opts_or_str = {}, options = {})
        self.class.new(self, opts_or_str, options.merge(inverse: !@inverse))
      end

      def to_query
        @match_store.build
      end

      private

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
          if inverse?
            @match_store.antimatches[field] += Array(param)
          else
            @match_store.matches[field]     += Array(param)
          end
        end

    end
  end
end
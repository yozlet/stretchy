module Stretchy
  module Clauses
    class BoostWhereClause < BoostClause

      def initialize(base, options = {})
        super(base)
        where_function(:init, options)
      end

      def range(*args)
        options   = args.last.is_a?(Hash) ? args.pop : {}
        new_args  = args + [options.merge(method: :range)]
        where_function(:range, *new_args)
        self
      end

      def geo(*args)
        options   = args.last.is_a?(Hash) ? args.pop : {}
        new_args  = args + [options.merge(method: :geo)]
        where_function(:geo, *new_args)
        self
      end

      private

        def add_params(params = {})
          where_function(:init, params)
        end

        def where_function(method, *args)
          options   = args.last.is_a?(Hash) ? args.pop : {}
          weight    = options.delete(:weight)
          
          new_args  = args + [options.merge(method: :geo)]
          clause = WhereClause.tmp(options.merge(inverse: inverse?))
          clause = clause.send(method, *new_args) unless method == :init

          @boost_builder.functions << {
            filter: Stretchy::Filters::QueryFilter.new(clause.to_query),
            weight: weight
          }
        end
    end
  end
end
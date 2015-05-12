require 'stretchy/clauses/boost_clause'

module Stretchy
  module Clauses
    class BoostWhereClause < BoostClause

      def initialize(base, options = {})
        super(base, options)
        where_function(:init, options)
        self
      end

      def where(*args)
        WhereClause.new(self, *args)
      end

      def match(*args)
        MatchClause.new(self, *args)
      end

      def range(*args)
        where_function(:range, *args)
        Base.new(self)
      end

      def geo(*args)
        where_function(:geo, *args)
        Base.new(self)
      end

      private

        def add_params(params = {})
          where_function(:init, params)
        end

        def where_function(method, *args)
          options   = args.last.is_a?(Hash) ? args.pop : {}
          weight    = options.delete(:weight)

          clause    = nil
          if method == :init
            clause  = WhereClause.tmp(options.merge(inverse: inverse?))
          else
            args.push(options)
            clause  = WhereClause.tmp(inverse: inverse?).send(method, *args)
          end
          boost     = clause.to_boost(weight)

          @boost_builder.functions << boost if boost
        end
    end
  end
end
module Stretchy
  class API

    extend Forwardable

    delegate [:node] => :collector

    attr_reader :collector, :context

    def initialize(params = {})
      @collector = Collector.new
      clear_context!
    end

    def where(params = {})
      @context[:filter] = true unless @context[:query]
      return self unless params.any?

      params.each do |field, values|
        node = case values
        when Range
          add_range(field: field, value: values)
        when Array
          add_terms(field => values)
        else
          add_term(field => values)
        end
      end
      clear_context!
      self
    end

    def fulltext(params = {})
      @context[:query] = true
      return self unless params.any?

      if params.is_a?(String)
        add_match(_all: params)
      else
        params.each do |field, values|
          case values
          when Array
            @context[:should] = true
            add_match(field => values.join(' '))
          else
            add_match(field => values)
          end
        end
      end
      clear_context!
      self
    end

    def not(params = {})
      @context[:must_not] = true

      if context[:query]
        fulltext(params)
      elsif context[:filter]
        where(params)
      else
        raise 'call .query or .filter before .not' if params.any?
        return self
      end
      clear_context! if params.any?
      self
    end

    def should(params = {})
      @context[:should] = true

      if context[:query]
        fulltext(params)
      elsif context[:filter]
        where(params)
      else
        raise 'call .query or .filter before .should' if params.any?
        return self
      end
      clear_context! if params.any?
      self
    end

    def query(params = {})
      @context[:kind] = :query
      if params.any?
        collector.nodes << Node.new(context, values)
        clear_context!
      end
      self
    end

    def filter(params = {})
      @context[:kind] = :filter
      if params.any?
        collector.nodes << Node.new(context, params)
        clear_context!
      end
      self
    end

    def json
      {
        query: node.json
      }
    end

    private
      def clear_context!
        @context = {
          query:    false,
          filter:   false,
          must_not: false,
          should:   false
        }
      end

      def add_range(params = {})
        field = params.delete(:field)

        if params[:value].respond_to?(:min)
          value = params.delete(:value)
          params[:gte] = value.min
          params[:lte] = value.max
        end

        collector.nodes << Node.new(context,
          range: { field => params }
        )
      end

      def add_term(params = {})
        collector.nodes << Node.new(context, term: params)
      end

      def add_terms(params = {})
        collector.nodes << Node.new(context, terms: params)
      end

      def add_match(params = {})
        collector.nodes << Node.new(context, match: params)
      end

  end
end

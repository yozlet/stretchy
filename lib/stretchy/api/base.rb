require 'stretchy/utils/poro'
require 'stretchy/nodes/root'

module Stretchy
  module API
    class Base

      include Utils::Poro

      attribute :root,    Nodes::Root, default: -> { Nodes::Root.new }
      attribute :context, Context
      attribute :inverse, Axiom::Types::Boolean
      attribute :should,  Axiom::Types::Boolean
      attribute :nodes,   Array[Nodes::Base]

      attr_reader :query_context, :filter_context, :boost_context

      def after_initialize(options = {})
        @current      ||= root
        @query_context  = QueryContext.new( root: root, current: current)
        @filter_context = FilterContext.new(root: root, current: current)
        @boost_context  = BoostContext.new( root: root, current: current)
      end

      def query(params = {}, options = {})
        @context = @query_context
        @context.raw(params, options) if params.any?
        self
      end

      def filter(params = {}, options = {})
        @context = @filter_context
        @context.raw(params, options) if params.any?
        self
      end

      def boost(params = {}, options = {})
        @context = @boost_context
        @context.raw(params, options) if params.any?
        self
      end

      def not(params = {}, options = {})
        @inverse = true
        self
      end

      def should(params = {}, options = {})
        @should = true
        self
      end

      def method_missing(method, *args, **options, &block)
        context.send(method, *args, options, &block)
      end

    end
  end
end

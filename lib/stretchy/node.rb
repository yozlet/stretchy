module Stretchy
  class Node

    attr_reader :json, :context

    def initialize(context, json)
      @json     = json.dup
      @context  = context.dup
    end

  end
end

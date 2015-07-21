require 'stretchy/utils/poro'

module Stretchy
  module API
    class Context

      include Utils::Poro

      attribute :root,    Nodes::Root
      attribute :current, Nodes::Base
      attribute :base,    Base

      validations do
        rule :root,    type: Nodes::Root, required: true
        rule :current, type: Nodes::Base, required: true
        rule :base,    type: Base,        required: true
      end

      def after_initialize(options = {})
        @current ||= root
      end
    end
  end
end

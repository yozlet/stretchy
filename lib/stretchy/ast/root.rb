module Stretchy
  module AST
    class Root < Base

      attribute :index,   String
      attribute :type,    String
      attribute :query,   Base
      attribute :filter,  Base
      attribute :aggs,    Base
      attribute :from,    Integer
      attribute :size,    Integer
      attribute :fields,  Array

      validations do
        rule :index, required: true
        rule :type,  required: true
      end

    end
  end
end

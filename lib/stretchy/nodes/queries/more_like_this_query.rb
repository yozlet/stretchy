require 'stretchy/nodes/queries/base'

module Stretchy
  module Nodes
    module Queries
      class MoreLikeThisQuery < Base

        attribute :fields,          Array[String]
        attribute :like_text,       String
        attribute :ids,             Array[Integer]
        attribute :docs,            Array
        attribute :max_query_terms, Integer
        attribute :min_term_freq,   Integer
        attribute :min_doc_freq,    Integer
        attribute :max_doc_freq,    Integer
        attribute :min_word_length, Integer
        attribute :max_word_length, Integer
        attribute :stop_words,      Array[String]
        attribute :analyzer,        String
        attribute :boost_terms,     Integer
        attribute :include,         Axiom::Types::Boolean
        attribute :boost,           Float

        validations do
          rule :fields, field: { array: true }
        end

        def after_initialize(params = {})
          if params[:docs]
            @docs = coerce_docs(Array(params[:docs]))
          end

          require_one!(:like_text, :docs, :ids)
        end

        def coerce_docs(docs)
          docs.map do |doc|
            coerced = {
              '_index'  => doc['_index']  || doc[:_index],
              '_type'   => doc['_type']   || doc[:_type],
            }

            source = doc[:doc] || doc['']
            if source
              coerced['doc'] = source
            else
              coerced['_id'] = doc['_id'] || doc[:_id]
            end
            coerced
          end
        end

        def to_search
          {
            more_like_this: json_attributes
          }
        end
      end
    end
  end
end

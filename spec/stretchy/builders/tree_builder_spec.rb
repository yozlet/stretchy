require 'spec_helper'

describe Stretchy::Builders::TreeBuilder do

  describe 'can parse' do

    def parse(tree)
      described_class.parse(tree)
    end

    it 'a simple query' do
      tree = [:root,
        [:and,
          [:filter,
            [:terms, {a: :b}]],
          [:filter,
            [:terms, {c: :d}]]],
        {from: 0}
      ]
      expect(parse(tree)).to eq(
        filters: [
          { terms: { a: [:b] } },
          { terms: { c: [:d] } }
        ],
        from: 0
      )
    end

    it 'multiple filters and matches' do
      tree = [:root,
        [:and,
          [:and,
            [:filter,
              [:terms, {a: :b}]],
            [:filter,
              [:terms, {a: :c}]]
          ],
          [:and,
            [:query,
              [:match, {d: :e}, {type: :phrase, slop: 50}]],
            [:query,
              [:match, {f: :g}, {}]]
          ]
        ],
        {}
      ]

      expect(parse(tree)).to eq(
        filters: [
          { terms: { a: [:b, :c] }}
        ],
        queries: [
          { match: { d: { query: :e, type: :phrase, slop: 50 }}},
          { match: { f: { query: :g }}}
        ]
      )
    end

  end

  context 'can flatten' do

    def flatten(hash)
      described_class.flatten(hash)
    end

    it 'filters' do
      hash = {
        filters: [
          { terms: { a: [:b] }},
          { terms: { c: [:d] }},
          { terms: { a: [:d] }}
        ]
      }

      expect(flatten(hash)).to eq(
        filters: [
          { terms: { a: [:b, :d] }},
          { terms: { c: [:d] }}
        ]
      )
    end

  end

end

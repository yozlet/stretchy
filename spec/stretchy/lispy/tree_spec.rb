require 'spec_helper'

describe Stretchy::Lispy::Tree do

  def flatten(tree)
    Stretchy::Lispy::Tree.new(tree).flatten
  end

  def assert_equal(first, second)
    expect(first).to eq(second)
  end

  it 'flattens a where tree' do
    assert_equal({
      where: [
        {a: 2}
      ]
    }, flatten([:where, {a: 2}]))
  end

  it 'flattens an and tree' do
    assert_equal({
      where: [
        {a: 1},
        {b: 2}
      ]
    }, flatten([:and, [:where, {a: 1}], [:and, [:where, {b: 2}]]]))
  end

  it 'flattens an and tree' do
    assert_equal({
      where: [
        {b: 2}
      ],
      not: {
        where: [
          {a: 1}
        ]
      }
    }, flatten([:and, [:not, [:where, {a: 1}]], [:and, [:where, {b: 2}]]]))
  end

  it 'flattens a tree' do
    assert_equal({
      where: [
        {b: 2}
      ],
      not: {
        where: [
          {a: 1}
        ]
      }
    }, Stretchy::Lispy::Tree.new(nil).not_where(a:1).where(b:2).flatten)
  end
end

require 'spec_helper'

describe Stretchy::Utils do

  subject { Stretchy::Utils }

  it 'deep merges hashes' do
    first       = {one: {two: :three}, four: {five: {six: :seven}}}
    first_copy  = first.dup
    second      = {eight: {nine: :ten}, one: {two: :eleven}, four: {twelve: {thirteen: :fourteen}}}
    result      = subject.deep_merge(first, second)

    expect(result).to eq(
      {
        one: {two: :eleven},
        four: {
          five: {six: :seven},
          twelve: {thirteen: :fourteen}
        },
        eight: {nine: :ten}
      }
    )
    expect(result.object_id).to_not eq(first.object_id)
    expect(first).to eq(first_copy)
  end

  it 'concats arrays with deep merge' do
    first       = {one: {two: [:three]}, four: [:five, :six]}
    first_copy  = first.dup
    second      = {one: {two: [:seven]}, four: [:eight], nine: [:ten, :eleven]}
    result      = subject.deep_merge(first, second)

    expect(result).to eq(
      {
        one: {
          two: [:three, :seven]
        },
        four: [:five, :six, :eight],
        nine: [:ten, :eleven]
      }
    )
  end

end

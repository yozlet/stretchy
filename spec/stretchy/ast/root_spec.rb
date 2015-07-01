require 'spec_helper'

describe Stretchy::AST::Root do
  subject { described_class.new(index: SPEC_INDEX, type: FIXTURE_TYPE) }

  it 'compiles' do
    expect{subject.compile}.to_not raise_error
  end

  it 'compiles with child node' do
    subject.query = Stretchy::AST::MatchQuery.new(field: 'name', query: 'masahiro')
    pp subject.compile
  end

end

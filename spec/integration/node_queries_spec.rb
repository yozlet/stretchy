require 'spec_helper'

describe 'the api' do

  subject { Stretchy.api }

  it 'can construct a node' do
    instance = subject.where(one: :two)
    expect(subject.tree)
  end

end

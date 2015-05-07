require 'spec_helper'

describe Stretchy::Types::Base do

  it 'requires an initialization override' do
    expect{subject}.to raise_error
  end

end
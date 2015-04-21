require 'spec_helper'

describe Stretchy::Boosts::Base do

  subject { Stretchy::Boosts::Base }

  it 'errors on initialize' do
    expect{subject.new}.to raise_error
  end

end
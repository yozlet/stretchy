require 'spec_helper'

describe Stretchy do
  it 'has a version number' do
    expect(Stretchy::VERSION).not_to be nil
  end

  # most config methods are called in spec_helper
  # so we've already verified they work

  it 'has a singleton client' do
    expect(Stretchy.client).to be_a(Elasticsearch::Transport::Client)
    expect(Stretchy.client.object_id).to eq(Stretchy.client.object_id)
  end
end

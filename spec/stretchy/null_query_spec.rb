require 'spec_helper'

describe Stretchy::NullQuery do

  # you can return a NullQuery instead of an invalid query
  # so end-user objects will still be able to call
  # result-related methods
  it 'emulates query results' do
    [:response, :id_response, :results, :ids, :shards].each do |field|
      expect(subject.send(field)).to be_empty
    end

    expect(subject.total).to eq(0)
  end

end
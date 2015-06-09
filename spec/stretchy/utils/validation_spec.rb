require 'spec_helper'

describe Stretchy::Utils::Validation do

  class ValidClass
    include Stretchy::Utils::Validation

    attribute :name
    attribute :example

    validations do
      rule :name, :field
    end

    def after_initialize(params = {})
      raise "Invalid" if params[:name] == :invalid_value
    end
  end

  let(:klass) { ValidClass }
  subject { klass.new(name: :one) }

  it 'initializes with validations' do
    expect(subject.name).to eq(:one)
  end

  it 'validates after initialize' do
    expect{klass.new}.to raise_error
  end

  it 'calls after_initialize' do
    expect{klass.new(name: :invalid_value)}.to raise_error
  end

  it 'returns json_attributes' do
    json = klass.new(
      name: :valid_value,
      example: :name
    ).json_attributes
    
    expect(json[:name]).to eq(:valid_value)
    expect(json[:example]).to eq(:name)
  end

end
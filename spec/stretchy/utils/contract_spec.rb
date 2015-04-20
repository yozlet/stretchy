require 'spec_helper'

describe Stretchy::Utils::Contract do

  class MyContractable
    include Stretchy::Utils::Contract

    contract :str,          type: String
    contract :str_arr,      type: String, array: true
    contract :oneof,        type: String, in: ['boom', 'headshot']
    contract :oneof_arr,    type: String, in: ['boom', 'headshot'], array: true
    contract :respond,      responds_to: :to_custom
    contract :respond_arr,  responds_to: :to_custom, array: true
    contract :matched,      matches: /units/
    contract :matched_arr,  matches: /units/, array: true
    contract :dist,         type: :distance
    contract :lat,          type: :lat
    contract :lng,          type: :lng
    contract :field,        type: :field

    def initialize(options = {})
      options.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
      validate!
    end
  end

  class CustomResponder
    def to_custom
      # noop
    end
  end

  let(:error_klass) { Stretchy::Errors::ContractError }
  let(:valid_params) do
    {
      str:          'A string',
      str_arr:      ['An array', 'of strings'],
      oneof:        'boom',
      oneof_arr:    ['headshot'],
      respond:      CustomResponder.new,
      respond_arr:  [CustomResponder.new, CustomResponder.new],
      matched:      '50 units',
      matched_arr:  ['50 units'],
      dist:         '20km',
      lat:          45.01,
      lng:          133.21,
      field:        :json_field
    }
  end

  subject { MyContractable }

  def check_raises_error(params)
    expect{subject.new(valid_params.merge(params))}.to raise_error(error_klass)
  end

  it 'can initialize with valid attributes' do
    expect{subject.new(valid_params)}.to_not raise_error
  end

  describe 'raises error when' do

    it 'type assertion fails' do
      check_raises_error str: 123
      check_raises_error str_arr: 123
      check_raises_error str_arr: ['str', 123, 'str']
    end

    it 'distance type fails' do
      check_raises_error dist: 'wat'
    end

    it 'lat type fails' do
      check_raises_error lat: 'mars'
      check_raises_error lat: 999
      check_raises_error lat: -999
    end

    it 'lng type fails' do
      check_raises_error lng: 'jupiter'
      check_raises_error lng: 999
      check_raises_error lng: -999
    end

    it 'field type fails' do
      check_raises_error field: Stretchy::Queries::MatchAllQuery.new
      check_raises_error field: ['array', 'elems']
      check_raises_error field: ''
    end

    it 'collection check fails' do
      check_raises_error oneof: 'not boom or headshot'
      check_raises_error oneof_arr: 'not boom or headshot'
      check_raises_error oneof_arr: ['not boom or headshot']
    end

    it 'respond_to check fails' do
      check_raises_error respond: 1234
      check_raises_error respond_arr: 1234
      check_raises_error respond_arr: [1234]
    end

    it 'matches check fails' do
      check_raises_error matched: '50 credits'
      check_raises_error matched_arr: '50 units'
      check_raises_error matched_arr: ['50 credits']
    end
  end

end
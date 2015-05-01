require 'spec_helper'

describe Stretchy::Filters::GeoFilter do

  let(:field) { 'coords' }
  let(:distance) { '50km' }
  let(:lat) { 35.0117 }
  let(:lng) { 135.7683 }

  subject { Stretchy::Filters::GeoFilter }

  def get_result(*args)
    subject.new(*args).to_search[:geo_distance]
  end

  it 'returns json for geo filter' do
    result = get_result(field: field, distance: distance, lat: lat, lng: lng)
    expect(result[:distance]).to eq(distance)
    expect(result[field][:lat]).to eq(lat)
    expect(result[field][:lon]).to eq(lng)
  end

  it 'raises error unless distance is present' do
    expect{subject.new(field: field, lat: lat, lng: lng)}.to raise_error
  end

  it 'raises error unless field is present' do
    expect{subject.new(distance: '50km', lat: lat, lng: lng)}.to raise_error
  end

  it 'raises error unless lat and lng are passed' do
    expect{subject.new(field: field, distance: distance, lat: lat)}.to raise_error
    expect{subject.new(field: field, distance: distance, lng: lng)}.to raise_error
    expect{subject.new}.to raise_error
  end

  it 'raises error unless appropriate types are passed' do
    expect{subject.new(field: ['array'], distance: distance, lat: lat, lng: lng)}.to raise_error
    expect{subject.new(field: field, distance: 'not_a_distance', lat: lat, lng: lng)}.to raise_error
    expect{subject.new(field: field, distance: distance, lat: 'wat', lng: lng)}.to raise_error
    expect{subject.new(field: field, distance: distance, lat: lat, lng: 'wat')}.to raise_error
  end

  it 'raises error if any params are blank' do
    expect{subject.new(field: '', distance: distance, lat: lat, lng: lng)}.to raise_error
    expect{subject.new(field: field, distance: '', lat: lat, lng: lng)}.to raise_error
  end

  it 'raises error unless lat/lng are valid coords' do
    expect{subject.new(field: field, distance: distance, lat: 'wat', lng: lng)}.to raise_error
    expect{subject.new(field: field, distance: distance, lat: lat, lng: 999)}.to raise_error
  end
end
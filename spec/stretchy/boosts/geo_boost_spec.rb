require 'spec_helper'

describe Stretchy::Boosts::GeoBoost do

  subject { Stretchy::Boosts::GeoBoost }
  let(:field) { 'coords' }
  let(:offset) { '20km' }
  let(:scale) { '100km' }
  let(:decay) { 0.5 }
  let(:weight) { 5 }
  let(:lat) { 35.0117 }
  let(:lng) { 135.7683 }

  def get_result(*args)
    subject.new(*args).to_search
  end

  it 'returns json for filter boost with gauss decay' do
    result = get_result(
      field: field,
      offset: offset,
      scale: scale,
      decay: decay,
      weight: weight,
      lat: lat,
      lng: lng
    )
    expect(result[:gauss]).to be_a(Hash)
    expect(result[:gauss][field][:origin][:lat]).to eq(lat)
    expect(result[:gauss][field][:origin][:lon]).to eq(lng)
    expect(result[:gauss][field][:offset]).to eq(offset)
    expect(result[:gauss][field][:scale]).to eq(scale)
    expect(result[:gauss][field][:decay]).to eq(decay)
    expect(result[:weight]).to eq(weight)
  end

  it 'requires lat, lng, field and scale params' do
    result = get_result(field: field, scale: scale, lat: lat, lng: lng)
    expect(result[:gauss][field][:origin][:lat]).to eq(lat)
    expect(result[:gauss][field][:origin][:lon]).to eq(lng)
    expect(result[:gauss][field][:scale]).to eq(scale)
    expect(result[:gauss][field][:offset]).to eq(Stretchy::Boosts::GeoBoost::DEFAULTS[:offset])
    expect(result[:gauss][field][:decay]).to eq(Stretchy::Boosts::GeoBoost::DEFAULTS[:decay])
    expect(result[:weight]).to eq(Stretchy::Boosts::GeoBoost::DEFAULTS[:weight])
  end

  it 'raises error unless lat and lng are valid coords' do
    expect{subject.new(field: field, lat: 'wat', lng: lng)}.to raise_error
  end

  it 'raises error unless lat and lng exist on Earth' do
    expect{subject.new(field: field, lat: lat, lng: 999)}.to raise_error
  end

  it 'raises error unless offset and scale are appropriate type' do
    expect{subject.new(field: field, lat: lat, lng: lng, offset: 'invalid')}.to raise_error
    expect{subject.new(field: field, lat: lat, lng: lng, scale: 'invalid')}.to raise_error
  end

  it 'raises error unless weight is numeric' do
    expect{subject.new(field: field, lat: lat, lng: lng, weight: 'invalid')}.to raise_error
  end
end
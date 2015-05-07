require 'spec_helper'

describe Stretchy::Types::GeoPoint do

  it 'validates param presence' do
    expect{subject}.to raise_error
  end

  it 'validates latitude' do
    expect{described_class.new(lat: 9000, lng: 30)}.to raise_error
  end

  it 'validates longitude' do
    expect{described_class.new(lat: 30, lng: 9000)}.to raise_error
  end

  describe 'produces valid json with' do

    specify 'latitude param' do
      expect(described_class.new(latitude: 23, lng: 40).to_search[:lat]).to eq(23)
    end

    specify 'lat param' do
      expect(described_class.new(lat: 23, lng: 40).to_search[:lat]).to eq(23)
    end

    specify 'lng param' do
      expect(described_class.new(lat: 23, lng: 40).to_search[:lon]).to eq(40)
    end

    specify 'lon param' do
      expect(described_class.new(lat: 23, lon: 40).to_search[:lon]).to eq(40)
    end

    specify 'longitude param' do
      expect(described_class.new(lat: 23, longitude: 40).to_search[:lon]).to eq(40)
    end
  end

end
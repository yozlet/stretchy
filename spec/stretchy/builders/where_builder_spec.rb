require 'spec_helper'

describe Stretchy::Builders::WhereBuilder do

  it 'instantiates' do
    expect(subject).to be_a(described_class)
  end

  it 'checks field existence' do
    subject.exists += [:fieldname]
    result = subject.build
    expect(result).to be_a(Stretchy::Filters::ExistsFilter)
  end

  context 'bool filter' do
    let(:result) { subject.build.to_search }

    it 'excludes nils' do
      subject.empties += [:fieldname]
      expect(result[:not][:exists][:field]).to eq(:fieldname)
    end

    it 'matches regular terms' do
      subject.terms[:fieldname] = [1, 3]
      expect(result[:terms][:fieldname]).to eq([1, 3])
    end

    it 'excludes regular terms' do
      subject.antiterms[:fieldname] = [1, 3]
      expect(result[:not][:terms][:fieldname]).to eq([1, 3])
    end

    it 'matches a range' do
      subject.ranges[:fieldname] = { min: 27, max: 33 }
      expect(result[:range][:fieldname][:gte]).to eq(27)
      expect(result[:range][:fieldname][:lte]).to eq(33)
    end

    it 'matches a min range' do
      subject.ranges[:fieldname] = { min: 27 }
      expect(result[:range][:fieldname][:gte]).to eq(27)
      expect(result[:range][:fieldname][:lte]).to be_nil
    end

    it 'matches a max range' do
      subject.ranges[:fieldname] = { max: 33 }
      expect(result[:range][:fieldname][:gte]).to be_nil
      expect(result[:range][:fieldname][:lte]).to eq(33)
    end

    it 'excludes a range' do
      subject.antiranges[:fieldname] = { min: 27, max: 33 }
      expect(result[:not][:range][:fieldname][:gte]).to eq(27)
      expect(result[:not][:range][:fieldname][:lte]).to eq(33)
    end

    it 'excludes a min range' do
      subject.antiranges[:fieldname] = { min: 27 }
      expect(result[:not][:range][:fieldname][:gte]).to eq(27)
      expect(result[:not][:range][:fieldname][:lte]).to be_nil
    end

    it 'excludes a max range' do
      subject.antiranges[:fieldname] = { max: 33 }
      expect(result[:not][:range][:fieldname][:gte]).to be_nil
      expect(result[:not][:range][:fieldname][:lte]).to eq(33)
    end

    it 'matches a geo distance' do
      subject.geos[:fieldname] = { distance: '33mi', lat: 27, lng: 33 }
      results = result[:geo_distance]
      expect(results[:fieldname][:lat]).to eq(27)
      expect(results[:fieldname][:lon]).to eq(33)
      expect(results[:distance]).to eq('33mi')
    end

    it 'excludes a geo distance' do
      subject.antigeos[:fieldname] = { distance: '27km', lat: 33, lng: 148 }
      results = result[:not][:geo_distance]
      expect(results[:fieldname][:lat]).to eq(33)
      expect(results[:fieldname][:lon]).to eq(148)
      expect(results[:distance]).to eq('27km')
    end

    it 'combines multiple positive queries' do
      subject.terms[:fieldname] = [1,3]
      subject.exists += [:other]
      results = result[:and]
      expect(results.first[:terms][:fieldname]).to eq([1,3])
      expect(results.last[:exists][:field]).to eq(:other)
    end

    it 'combines multiple negative queries' do
      subject.antiterms[:fieldname] = [1,3]
      subject.empties += [:other]
      results = result[:not][:and]
      expect(results.first[:terms][:fieldname]).to eq([1,3])
      expect(results.last[:exists][:field]).to eq(:other)
    end

    it 'combines positive and negative conditions to bool filter' do
      subject.terms[:fieldname] = [1,3]
      subject.antiterms[:other] = [4,5]
      results = result[:bool]
      expect(results[:must].first[:terms][:fieldname]).to eq([1,3])
      expect(results[:must_not].first[:terms][:other]).to eq([4,5])
    end
  end

end
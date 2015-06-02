require 'spec_helper'

describe Stretchy::Builders::WhereBuilder do

  it 'instantiates' do
    expect(subject).to be_a(described_class)
  end

  it 'checks field existence' do
    subject.add_param(:fieldname, nil, inverse: true)
    result = subject.to_filter
    expect(result).to be_a(Stretchy::Filters::ExistsFilter)
  end

  context 'bool filter' do
    let(:result) { subject.to_filter.to_search }
    let(:range_type) { Stretchy::Types::Range }

    context 'single positive filter' do
      it 'matches regular terms' do
        subject.add_param(:fieldname, [1, 3])
        expect(result[:terms][:fieldname]).to eq([1, 3])
      end

      it 'matches a range' do
        subject.add_range(:fieldname, range_type.new(27..33))
        expect(result[:range][:fieldname][:gte]).to eq(27)
        expect(result[:range][:fieldname][:lte]).to eq(33)
      end

      it 'matches a min range' do
        subject.add_range(:fieldname, range_type.new(min: 27))
        expect(result[:range][:fieldname][:gte]).to eq(27)
        expect(result[:range][:fieldname][:lte]).to be_nil
      end

      it 'matches a max range' do
        subject.add_range(:fieldname, range_type.new(max: 33))
        expect(result[:range][:fieldname][:gte]).to be_nil
        expect(result[:range][:fieldname][:lte]).to eq(33)
      end

      it 'matches a geo distance' do
        subject.add_geo(:fieldname, '33mi', lat: 27, lng: 33)
        # subject.geos[:fieldname] = { distance: '33mi', lat: 27, lng: 33 }
        results = result[:geo_distance]
        expect(results[:fieldname][:lat]).to eq(27)
        expect(results[:fieldname][:lon]).to eq(33)
        expect(results[:distance]).to eq('33mi')
      end
    end

    context 'multiple positive filters' do
      let(:result) { subject.to_filter.to_search[:and] }

      it 'combines multiple positive queries' do
        subject.add_param(:fieldname, [1,3])
        subject.add_param(:other, nil, inverse: true)
        expect(result.first[:terms][:fieldname]).to eq([1,3])
        expect(result.last[:exists][:field]).to eq('other')
      end
    end

    context 'single negative filter' do
      let(:result) { subject.to_filter.to_search[:not] }
      
      it 'excludes nils' do
        subject.add_param(:fieldname, nil)
        expect(result[:exists][:field]).to eq('fieldname')
      end

      it 'excludes regular terms' do
        subject.add_param(:fieldname, [1, 3], inverse: true)
        expect(result[:terms][:fieldname]).to eq([1, 3])
      end
      
      it 'excludes a range' do
        subject.add_param(:fieldname, range_type.new(min: 27, max: 33), inverse: true)
        expect(result[:range][:fieldname][:gte]).to eq(27)
        expect(result[:range][:fieldname][:lte]).to eq(33)
      end

      it 'excludes a min range' do
        subject.add_param(:fieldname, range_type.new(min: 27), inverse: true)
        expect(result[:range][:fieldname][:gte]).to eq(27)
        expect(result[:range][:fieldname][:lte]).to be_nil
      end

      it 'excludes a max range' do
        subject.add_param(:fieldname, range_type.new(max: 33), inverse: true)
        expect(result[:range][:fieldname][:gte]).to be_nil
        expect(result[:range][:fieldname][:lte]).to eq(33)
      end

      it 'excludes a geo distance' do
        subject.add_geo(:fieldname, '27km', lat: 33, lng: 148, inverse: true)
        results = result[:geo_distance]
        expect(results[:fieldname][:lat]).to eq(33)
        expect(results[:fieldname][:lon]).to eq(148)
        expect(results[:distance]).to eq('27km')
      end
    end

    context 'multiple negative filters' do
      let(:result) { subject.to_filter.to_search[:not][:or] }

      it 'combines multiple negative queries' do
        subject.add_param(:fieldname, [1, 3], inverse: true)
        subject.add_param(:other, nil)
        expect(result.first[:terms][:fieldname]).to eq([1,3])
        expect(result.last[:exists][:field]).to eq('other')
      end
    end

    context 'boolean filters' do
      let(:result) { subject.to_filter.to_search[:bool] }

      it 'combines positive and negative conditions to bool filter' do
        subject.add_param(:fieldname, [1,3])
        subject.add_param(:other, [4,5], inverse: true)
        expect(result[:must].first[:terms][:fieldname]).to eq([1,3])
        expect(result[:must_not].first[:terms][:other]).to eq([4,5])
      end

      context 'with single should clause' do
        let(:result) { subject.to_filter.to_search[:bool][:should].first }
        
        it 'accepts should terms' do
          subject.add_param(:fieldname, [1, 2], should: true)
          expect(result[:terms][:fieldname]).to eq([1, 2])
        end

        it 'excludes should terms' do
          subject.add_param(:fieldname, [1, 3], should: true, inverse: true)
          expect(result[:not][:terms][:fieldname]).to eq([1, 3])
        end

        it 'accepts should exists' do
          subject.add_param(:field, nil, inverse: true, should: true)
          expect(result[:exists][:field]).to eq('field')
        end

        it 'accepts should not exists' do
          subject.add_param(:fieldname, nil, should: true)
          expect(result[:not][:exists][:field]).to eq('fieldname')
        end

        it 'accepts should range' do
          subject.add_param(:fieldname, range_type.new(min: 27, max: 34), should: true)
          expect(result[:range][:fieldname]).to eq(gte: 27, lte: 34)
        end

        it 'accepts should range with min' do
          subject.add_param(:fieldname, range_type.new(min: 27), should: true)
          expect(result[:range][:fieldname]).to eq(gte: 27)
        end

        it 'accepts should range with max' do
          subject.add_param(:fieldname, range_type.new(max: 34), should: true)
          expect(result[:range][:fieldname]).to eq(lte: 34)
        end

        it 'accepts should not range' do
          subject.add_param(:fieldname, range_type.new(min: 27, max: 34), should: true, inverse: true)
          expect(result[:not][:range][:fieldname]).to eq(gte: 27, lte: 34)
        end

        it 'accepts should not range with min' do
          subject.add_param(:fieldname, range_type.new(min: 27), should: true, inverse: true)
          expect(result[:not][:range][:fieldname]).to eq(gte: 27)
        end

        it 'accepts should not range with max' do
          subject.add_param(:fieldname, range_type.new(max: 27), should: true, inverse: true)
          expect(result[:not][:range][:fieldname]).to eq(lte: 27)
        end

        it 'accepts a geo distance' do
          subject.add_geo(:fieldname, '93km', lat: 33, lng: 42, should: true)
          results = result[:geo_distance]
          expect(results[:fieldname]).to eq(lat: 33, lon: 42)
          expect(results[:distance]).to eq('93km')
        end

        it 'accepts a geo distance' do
          subject.add_geo(:fieldname, '93km', geo_point: Stretchy::Types::GeoPoint.new(lat: 33, lng: 42), should: true)
          results = result[:geo_distance]
          expect(results[:fieldname]).to eq(lat: 33, lon: 42)
          expect(results[:distance]).to eq('93km')
        end

        it 'accepts not geo distance' do
          subject.add_geo(:fieldname, '93km', 
            geo_point: Stretchy::Types::GeoPoint.new(lat: 33, lng: 42), 
            should: true,
            inverse: true
          )
          results = result[:not][:geo_distance]
          expect(results[:fieldname]).to eq(lat: 33, lon: 42)
          expect(results[:distance]).to eq('93km')
        end
      end
    end
  end
end
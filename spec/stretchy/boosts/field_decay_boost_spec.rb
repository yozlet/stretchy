require 'spec_helper'

describe Stretchy::Boosts::FieldDecayBoost do

  let(:params) do
    {
      field: :published_at,
      origin: Time.now,
      scale: '10d'
    }
  end

  it 'fails on blank initialize' do
    expect{described_class.new}.to raise_error
  end

  it 'fails without field param' do
    expect{described_class.new(origin: params[:origin], scale: params[:scale])}.to raise_error
  end

  it 'fails without origin param' do
    expect{described_class.new(field: params[:field], scale: params[:scale])}.to raise_error
  end

  it 'fails without scale param' do
    expect{described_class.new(field: params[:field], origin: params[:origin])}.to raise_error
  end

  describe 'produces correct json output for' do

    def get_result(*args)
      described_class.new(*args).to_search
    end

    specify 'required fields' do
      result = get_result(params)
      expect(result[:gauss]).to be_a(Hash)
      expect(result[:gauss][params[:field]][:origin]).to eq(params[:origin])
      expect(result[:gauss][params[:field]][:scale]).to eq(params[:scale])
    end

    specify 'offset' do
      result = get_result(params.merge(offset: '1d'))
      expect(result[:gauss][params[:field]][:offset]).to eq('1d')
    end

    specify 'weight' do
      result = get_result(params.merge(weight: 13))
      expect(result[:weight]).to eq(13)
    end

    specify 'type' do
      result = get_result(params.merge(type: :exp))
      expect(result[:exp]).to be_a(Hash)
      expect(result[:exp][params[:field]][:origin]).to eq(params[:origin])
      expect(result[:exp][params[:field]][:scale]).to eq(params[:scale])
    end

    specify 'decay' do
      result = get_result(params.merge(decay: 0.5))
      expect(result[:gauss][params[:field]][:decay]).to eq(0.5)
    end
  end

end
require 'spec_helper'

describe Stretchy::Clauses::WhereClause do
  let(:base) { Stretchy::Builders::ShellBuilder.new }
  let(:match_builder) { Stretchy::Builders::MatchBuilder }
  let(:where_builder) { Stretchy::Builders::WhereBuilder }
  let(:params_filter) { Stretchy::Filters::ParamsFilter }

  context 'initializes with' do
    specify 'base' do
      instance = described_class.new(base)
      expect(instance.inverse?).to eq(false)
      expect(instance.should?).to eq(false)
    end
  end

  describe 'can add a' do

    subject { described_class.new(base) }

    specify 'geo field' do
      expect_any_instance_of(where_builder).to receive(:add_geo).with(
        :geo_field, '27km',
        distance: '27km',
        lat: 34.3,
        lng: 28.2
      )
      subject.geo(:geo_field, distance: '27km', lat: 34.3, lng: 28.2)
    end

    specify 'range with min' do
      expect_any_instance_of(where_builder).to receive(:add_range).with(
        :range_field,
        min:     88
      )
      subject.range(:range_field, min: 88)
    end

    specify 'range with max' do
      expect_any_instance_of(where_builder).to receive(:add_range).with(
        :range_field,
        max:     99
      )
      subject.range(:range_field, max: 99)
    end

    specify 'arbitrary json filter' do
      expect_any_instance_of(where_builder).to receive(:add_filter).with(
        params_filter, {}
      )
      subject.filter(foo: {bar: :baz})
    end

    specify 'inverse options' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :number_field, 27,
        inverse: true
      )
      subject.not(number_field: 27)
    end

    specify 'should options' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :number_field, 27,
        should:  true
      )
      subject.should(number_field: 27)
    end

    specify 'should not options' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :number_field, 27,
        inverse: true,
        should:  true
      )
      subject.should.not(number_field: 27)
    end

    specify 'should not and where options' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :not_field, 27,
        inverse: true,
        should:  true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :should_field, 33,
        should:  true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :where_field, 42, {}
      )

      subject.should.not(not_field: 27).should(should_field: 33).where(where_field: 42)
    end

    specify 'where not / should options' do
      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :not_field, 27,
        inverse: true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :should_field, 33,
        should:  true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :should_not_one, 88,
        inverse: true,
        should:  true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :other_not, 42,
        inverse: true
      )

      expect_any_instance_of(where_builder).to receive(:add_param).with(
        :should_not_two, 22,
        inverse: true,
        should:  true
      )
      subject.not(not_field: 27).should(should_field: 33).not(should_not_one: 88)
                        .where.not(other_not: 42).should.not(should_not_two: 22)
    end
  end

  it 'converts to boost' do
    instance = described_class.new(base).where(
      number_field: 27,
      string_field: 'hello',
      nil_field: nil,
      range_field: 34..99
    )
    boost = instance.to_boost
    expect(boost).to be_a(Stretchy::Boosts::FilterBoost)
  end

end

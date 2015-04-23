require 'spec_helper'

describe Stretchy::Builders::WhereBuilder do

  it 'instantiates' do
    expect(subject).to be_a(described_class)
  end

  it 'can add nils' do
    subject.add_nil(:fieldname)
    subject.add_nil(:other_field, inverse: true)
    expect(subject.exists).to eq([:other_field])
    expect(subject.empties).to eq([:fieldname])
  end

  it 'can add a string' do
    subject.add_string(:fieldname, 'mystring')
    subject.add_string(:other_field, 'otherstring', inverse: true)
    expect(subject.matches).to include(fieldname: ['mystring'])
    expect(subject.antimatches).to include(other_field: ['otherstring'])
  end

  it 'can add a range hash' do
    subject.add_range(:field, min: 23, max: 68)
    subject.add_range(:field2, min: 22)
    subject.add_range(:field3, max: 70)
    subject.add_range(:field5, min: 99, max: 300, inverse: true)
    subject.add_range(:field4, min: 22, inverse: true)
    subject.add_range(:field6, max: 33, inverse: true)
  end

end
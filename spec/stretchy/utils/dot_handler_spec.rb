require 'spec_helper'

describe Stretchy::Utils::DotHandler do
  subject { described_class }

  it 'converts dot-notations to a nested hash' do
    result = subject.convert_from_dotted_keys(
      'top.child.bottom'  => [:bottom_elem],
      'top.child.wtf'     => [:wtf_elem],
      'top.other_child'   => :other_child_elem
    )
    
    expect(result).to eq(
      'top' => {
        'child' => {
          'bottom' => [:bottom_elem],
          'wtf'    => [:wtf_elem]
        },
        'other_child' => :other_child_elem
      }
    )
  end

  # can't believe how hard this is to do well
  xit 'recursively converts dotted keys' do
    result = subject.convert_from_dotted_keys(
      'top.child' => {
        'grandchild.greatgranchild' => :greatgranchild_elem
      }
    )
    
    expect(result).to eq(
      'top' => {
        'child' => {
          'grandchild' => {
            'greatgranchild' => :greatgranchild_elem
          }
        }
      }
    )
  end
end
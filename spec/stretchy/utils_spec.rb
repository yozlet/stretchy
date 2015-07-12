require 'spec_helper'

module Stretchy
  describe Utils do

    subject { described_class }

    describe '#underscore' do

      specify 'ClassNames' do
        expect(subject.underscore('ClassName')).to eq('class_name')
      end

      specify 'snake-Cased-strings' do
        expect(subject.underscore('snake-Cased-strings')).to eq('snake_cased_strings')
      end

      specify 'ModuleName::ClassName' do
        expect(subject.underscore('ModuleName::ClassName')).to eq('module_name/class_name')
      end
    end
  end
end

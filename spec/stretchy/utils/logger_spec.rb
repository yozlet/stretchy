require 'spec_helper'

describe Stretchy::Utils::Logger do

  it 'can initialize with default attributes' do
    expect(subject).to be_a(described_class)
  end

  it 'can initialize with params' do
    expect(described_class.new(Logger.new(STDERR), :warn, 'red')).to be_a(described_class)
  end

  describe 'invalid params' do

    specify 'not a real logger' do
      expect{described_class.new('wat')}.to raise_error
    end

    specify 'not a real log level' do
      expect{described_class.new(nil, :fubared)}.to raise_error
    end

    specify 'not a real color for output' do
      expect{described_class.new(nil, :debug, :sky)}.to raise_error
    end

  end

  context 'logging to /dev/null' do
    let(:logger) { Logger.new('/dev/null') }
    subject { described_class.new(logger, :debug) }

    before do
      Stretchy::Utils::Colorize.colors.keys.each do |color|
        allow(Stretchy::Utils::Colorize).to receive(color) { |arg| arg }
      end
    end

    it 'can log a message' do
      expect(logger).to receive(:debug).with("A message")
      subject.log("A message")
    end

    it 'logs hashes and arrays' do
      expect(logger).to receive(:debug).with(JSON.pretty_generate({a: 'hash'}))
      subject.log({a: 'hash'})
    end

    it 'logs arrays' do
      expect(logger).to receive(:debug).with(JSON.pretty_generate([1, 'two']))
      subject.log([1, 'two'])
    end
  end

  it 'does not log if level is :silence' do
    expect(subject.base).not_to receive(:debug)
    subject.level = :silence
    subject.log("A string")
  end

end
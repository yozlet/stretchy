require 'json'
require 'stretchy/utils/colorize'
require 'stretchy/utils/poro'

module Stretchy
  module Utils
    class Logger

      include Poro

      LEVELS = [:silence, :debug, :info, :warn, :error, :fatal]

      attribute :base,  Symbol
      attribute :level, Symbol
      attribute :color, String

      validations do
        rule :base,   responds_to:  {method: LEVELS.last}
        rule :level,  inclusion:    {in: LEVELS}
        rule :color,  inclusion:    {in: Colorize::COLORS.keys}
      end

      def self.log(msg_or_obj)
        self.new.log(msg_or_obj)
      end

      def initialize(base = nil, level = nil, color = nil)
        @base  = base       || ::Logger.new(STDOUT)
        @level = level      || :silence
        @color = color      || :blue

        @color = @color.to_s if @color.is_a?(Symbol)

        validate!
      end

      def log(msg_or_obj, _level = nil, _color = nil)
        _level ||= level
        _color ||= color

        return if _level == :silence
        output = nil

        case msg_or_obj
        when String
          output = Colorize.send(_color, msg_or_obj)
        when Hash, Array
          output = Colorize.send(_color, JSON.pretty_generate(msg_or_obj))
        when Stretchy::Boosts::Base, Stretchy::Filters::Base, Stretchy::Queries::Base
          output = Colorize.send(_color, JSON.pretty_generate(msg_or_obj.to_search))
        else
          output = Colorize.send(_color, msg_or_obj.inspect)
        end

        base.send(_level, output)
      end

      LEVELS.each do |_level|
        define_method _level do |msg_or_obj, _color|
          send(log, _level, msg_or_obj)
        end
      end
    end
  end
end

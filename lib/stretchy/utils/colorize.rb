module Stretchy
  module Utils
    class Colorize
      COLORS = {
        "default" => "38",
        "black" => "30",
        "red" => "31",
        "green" => "32",
        "brown" => "33",
        "blue" => "34",
        "purple" => "35",
        "cyan" => "36",
        "gray" => "37",
        "dark gray" => "1;30",
        "light red" => "1;31",
        "light green" => "1;32",
        "yellow" => "1;33",
        "light blue" => "1;34",
        "light purple" => "1;35",
        "light cyan" => "1;36",
        "white" => "1;37"
      }.freeze

      BG_COLORS = {
        "default" => "0",
        "black" => "40",
        "red" => "41",
        "green" => "42",
        "brown" => "43",
        "blue" => "44",
        "purple" => "45",
        "cyan" => "46",
        "gray" => "47",
        "dark gray" => "100",
        "light red" => "101",
        "light green" => "102",
        "yellow" => "103",
        "light blue" => "104",
        "light purple" => "105",
        "light cyan" => "106",
        "white" => "107"
      }.freeze

      def colorize(string, color = "default", bg = "default")
        color_code = COLORS[color]
        bg_code = BG_COLORS[bg]
        return "\033[#{bg_code};#{color_code}m#{string}\033[0m"
      end

      module ClassMethods
        def colors
          Colorize::COLORS
        end

        def bgs
          Colorize::BG_COLORS
        end

        Colorize::COLORS.keys.each do |color|
          define_method color do |string|
            color_code = colors[color]
            bg_code = bgs["default"]
            string.split("\n").map{|s| "\033[#{bg_code};#{color_code}m#{s}\033[0m" }.join("\n")
          end
        end
      end

      extend ClassMethods
    end
  end
end
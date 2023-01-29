require_relative '../minitest_helper'

module ResponsiveConsole
  module TestDisplayString
    def setup
      HashFormatter::FORMATS[:test] = "%k:\n  %V\n%k:\n  %V"
      ResponsiveConsole.config_width(@width ||= 80)

      @chars = [*'A'..'Z', *'a'..'z']
      elements = padded_chars(@range ||= 28..34)
      @nested_array = 3.times.map { 8.times.map { elements.shift } }
      @array_values = @nested_array.deep_dup.index_by(&:shift)
      @array_keys = @array_values.deep_dup.invert
    end

    def padded_chars(size_range)
      size_range = size_range..size_range unless size_range.is_a?(Range)
      sizes = size_range.cycle
      @chars.map { |c| format("%-#{sizes.peek}.#{sizes.next}s", c).gsub(' ', '_') }
    end

    def rstrip_lines(text)
      text.lines.map(&:rstrip).join("\n")
    end

    def subject_output(object)
      output = DisplayString.new(object).output(:test)
      rstrip_lines(output).tap { |o| puts o }
    end

    def test_existence
      refute_nil defined?(DisplayString)
    end
  end
end

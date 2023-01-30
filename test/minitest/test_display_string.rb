require_relative '../minitest_helper'

module ResponsiveConsole
  module TestDisplayString
    attr_writer :width, :lengths
    DEFAULT_WIDTH = 80
    DEFAULT_LENGTHS = 28..34
    ARRAY_FORMATS = {
      test_short: "[ %E, %E ]",
      test_long: "-- %E\n-- %E",
      test: :test_short
    }
    HASH_FORMATS = {
      test_short: '{ %k: %V, %k: %V }',
      test_long: "{\n  %k:  %V,\n  %k:  %V\n}",
      test: :test_short
    }

    def setup
      ResponsiveConsole.config_width(width)
      ArrayFormatter::FORMATS.merge!(ARRAY_FORMATS) { |_, orig, _| orig }
      HashFormatter::FORMATS.merge!(HASH_FORMATS) { |_, orig, _| orig }
    end

    def teardown
      ArrayFormatter::FORMATS.delete(:test)
      HashFormatter::FORMATS.delete(:test)
    end

    def width
      @width ||= DEFAULT_WIDTH
    end

    def lengths
      @lengths ||= DEFAULT_LENGTHS
    end

    def array_format=(val)
      ArrayFormatter::FORMATS[:test] = val
    end

    def hash_format=(val)
      HashFormatter::FORMATS[:test] = val
    end

    def padded_chars(size_range = lengths)
      size_range = size_range..size_range unless size_range.is_a?(Range)
      sizes = size_range.cycle
      [*'A'..'Z', *'a'..'z'].map { |c| "#{c}#{'~' * (sizes.next - 1)}" }
    end

    def nested_array
      padded_chars.first(12).each_slice(4).to_a
    end

    def array_values
      nested_array.index_by(&:shift)
    end

    def array_keys
      array_values.invert
    end

    def hash_elements
      nested_array.map { |el| el.each_slice(2).to_h }
    end

    def hash_values
      hash_elements.index_by { |h| h.keys.last }
    end

    def hash_keys
      hash_values.invert
    end

    def rstrip_lines(text)
      text.lines.map(&:rstrip).join("\n")
    end

    def subject_output(object)
      output = DisplayString.new(object).output(:test)
      rstrip_lines(output).tap { |o| puts [o, nil] }
    end
  end
end

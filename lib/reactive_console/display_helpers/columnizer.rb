module ConsoleHelpers
  class Columnizer
    MAX_COLUMNS = 7
    MIN_ELEMENTS = 3
    # TODO: This is actually appeneded to some lines, so having non-space chars doesn't work as intended
    COLUMN_JOINER = -'  '

    attr_reader :string, :key_option, :display_string
    delegate :temp_joiner, :joiner, :remaining_width, to: :display_string

    def initialize(str, display_string, **options)
      @display_string = display_string
      @string = str.split(temp_joiner).join(joiner)
      left_justified = options.fetch(:left_justified, !options[:right_justified])
      @key_option = left_justified ? :- : :+
    end

    def output
      return string if string.lines.size < MIN_ELEMENTS

      rows.map { |row| format(format_string, *row) }.join("\n")
    end

    def max_columns
      [string.lines.size, MAX_COLUMNS].min
    end

    def rows(cols = column_count)
      elements = string.lines(chomp: true)
      elements.push('') until elements.size.modulo(cols).zero?
      elements.each_slice(elements.size / cols).to_a.transpose
    end

    def format_string
      @format_string ||= formats_by_col[column_count]
    end

    def column_count
      @column_count ||= max_columns.downto(1).find do |cols|
        formatted = format(formats_by_col[cols], *Array.new(cols, ''))
        formatted.size <= remaining_width
      end
    end

    def formats_by_col
      @formats_by_col ||= Hash.new do |h, cols|
        longest = rows(cols).transpose.map { |col| col.max_by(&:size) }
        h[cols] = longest.map { |l| "%#{key_option}#{l.size}s" }.join(COLUMN_JOINER)
      end.tap { |h| h[1] = one_column_format }
    end

    def one_column_format
      "%-#{remaining_width}.#{remaining_width}s"
    end
  end
end

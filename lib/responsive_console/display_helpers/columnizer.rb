module ResponsiveConsole
  class Columnizer
    MAX_COLUMNS = 7
    MIN_ELEMENTS = 3
    # TODO: This is actually appended to some lines, so having non-space chars doesn't work as intended
    COLUMN_JOINER = -'  '

    attr_reader :string, :key_option, :display_string
    delegate :temp_joiner, :joiner, :remaining_width, to: :display_string

    def initialize(str, display_string, **options)
      @display_string = display_string
      # Because the first element seems to already has indentation applied because
      # of the element_prefix being written
      first_element, *elements = str.split(temp_joiner)
      indented_elements = elements.map { |el| el.gsub(/(?<=\n)/, joiner_indent) }
      @string = [first_element, *indented_elements].join(joiner)

      left_justified = options.fetch(:left_justified, !options[:right_justified])
      @key_option = left_justified ? :- : :+
    end

    def joiner_indent
      ' ' * joiner[/(?<=\n).*\z/].to_s.size
    end

    def output
      return string if string.lines.size < MIN_ELEMENTS

      rows.map { |row| format(format_string, *row) }.join("\n")
    end

    def max_columns
      [string.lines.size, MAX_COLUMNS].min
    end

    def rows(cols = column_count)
      # Ruby pre 2.6.3 didn't allow #lines(chomp: true)
      # elements = string.lines(chomp: true)
      elements = string.lines.map(&:chomp)
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
      end || 1
    end

    def formats_by_col
      @formats_by_col ||= Hash.new do |h, cols|
        longest = rows(cols).transpose.map { |col| col.max_by(&:size) }
        h[cols] = longest.map { |l| "%#{key_option}#{l.size}s" }.join(COLUMN_JOINER)
      end.tap { |h| h[1] = one_column_format }
    end

    def one_column_format
      width = [remaining_width, 0].max
      "%-#{width}.#{width}s"
    end
  end
end

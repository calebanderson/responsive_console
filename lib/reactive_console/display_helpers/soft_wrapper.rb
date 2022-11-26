module ConsoleHelpers
  class SoftWrapper
    attr_reader :string, :display_string
    delegate :temp_joiner, :joiner, :remaining_width, to: :display_string

    def initialize(str, display_string, **_options)
      @display_string = display_string
      @string = str.dup
    end

    def output
      rows.map { |r| r.join(joiner) }.join(line_joiner)
    end

    def line_joiner
      "#{joiner.rstrip}\n"
    end

    def rows
      row_elements = []
      string.split(temp_joiner).slice_before do |el|
        row_elements.clear if [*row_elements, el].join(joiner).size > remaining_width
      ensure
        row_elements.push(el)
      end
    end
  end
end

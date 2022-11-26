require "reactive_console/display_string"
require "reactive_console/version"
require "reactive_console/railtie"

module ReactiveConsole
  CONSOLE_WIDTH_RANGE = (80..800).freeze
  DEFAULT_CONSOLE_WIDTH = 250

  def width
    @width ||= DEFAULT_CONSOLE_WIDTH
  end

  def config_width(given_width = nil)
    input_width = given_width || _get_input_width
    return true if input_width.zero?

    if CONSOLE_WIDTH_RANGE.cover?(input_width)
      @width = input_width
      print('New ') & display_width if given_width.nil?
      true
    else
      puts "Width #{input_width} not within accepted range (#{CONSOLE_WIDTH_RANGE})"
    end
  end

  def _get_input_width
    display_width
    puts 'Press enter/return to accept. Enter a width or characters up to the desired limit, then press enter to set.'
    input = gets.chomp
    input.size < CONSOLE_WIDTH_RANGE.min && input[/^\d+$/] ? input.to_i : input.size
  end

  def display_width
    puts "Console Width: #{width}"
    puts '-' * width.to_i
  end
end

require "responsive_console/display_string"
require "responsive_console/version"
require "responsive_console/railtie"

module ResponsiveConsole
  class << self
    CONSOLE_WIDTH_RANGE = (80..800).freeze
    DEFAULT_CONSOLE_WIDTH = 250

    def width
      width = width_file.read.to_i
    rescue Errno::ENOENT, RangeError
      self.width = DEFAULT_CONSOLE_WIDTH
      DEFAULT_CONSOLE_WIDTH
    end

    def width=(val)
      val = CONSOLE_WIDTH_RANGE.cover?(val.to_i) && val.to_i
      raise ArgumentError, "width must be in range #{CONSOLE_WIDTH_RANGE}" unless val
      width_file.open(File::TRUNC | File::CREAT | File::WRONLY) { |f| f << val }
    end

    def width_file
      if defined?(Rails)
        Rails.root.join('.width.txt')
      else
        Pathname.new(File.expand_path('../../.width.txt', __FILE__))
      end
    end

    def config_width(given_width = nil)
      input_width = given_width || _get_input_width
      return true if input_width.zero?

      self.width = input_width
      print('New ') & display_width if given_width.nil?
      true
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
end

# frozen_string_literal: true

require_relative 'display_helpers/array_display_string'
require_relative 'display_helpers/collection_display_string'
require_relative 'display_helpers/columnizer'
require_relative 'display_helpers/formattable'
require_relative 'display_helpers/formatter'
require_relative 'display_helpers/hash_display_string'
require_relative 'display_helpers/object_display_string'
require_relative 'display_helpers/soft_wrapper'
require_relative 'display_helpers/writable'

module ResponsiveConsole
  class DisplayString
    include Formattable
    include Writable

    class << self
      def new(*args)
        return Class.new(self).new(*args) unless anonymous?

        super
      end
    end

    attr_reader :raw_input, :input

    def output(format = Formattable::DEFAULT)
      self.default_format = format
      # silence_stream($stderr) do # TODO: Implement check for #silence_stream (added by ActiveSupport)
      with_output_writer { write_object }
      # end
    end

    def initialize(input)
      case input
      when DisplayString
        @format = input.instance_variable_get(:@format) # Copy any explicit format
        return initialize(input.raw_input)
      when Hash then singleton_class.prepend(HashDisplayString)
      when Enumerable then singleton_class.prepend(ArrayDisplayString)
      else singleton_class.prepend(ObjectDisplayString)
      end

      @raw_input = input
    end

    def log_string(label = nil, &block)
      puts "===== #{label} =====" if label
      SharedHelpers.print_file_link(block.source_location)
      puts [block.call, nil]
    end

    module ObjectExt
      def console_helpers_as_display_string(format = nil)
        puts ResponsiveConsole::DisplayString.new(self).output(*format)
      end
      alias_method :chads, :console_helpers_as_display_string
    end
  end
end

Object.include(ResponsiveConsole::DisplayString::ObjectExt)
Object.extend(ResponsiveConsole::DisplayString::ObjectExt)

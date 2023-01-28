module ResponsiveConsole
  module Writable
    WRITER_KEY = :display_output_writer
    CURSOR_KEY = :display_output_cursor

    def write(msg)
      output_writer&.write(msg)
      msg
    end

    # Caching the object so forks can access the object (for example Lazy Enums use thread forks)
    def output_writer
      @output_writer ||= Thread.current[WRITER_KEY]
    end

    def output_writer=(val)
      Thread.current[WRITER_KEY] = val
      @output_writer = nil
    end

    def cursor_position
      str = output_writer&.string.to_s
      str.split(/\n/, -1).last.to_s.size # Second split arg allows trailing blank strings
    end

    def parent_cursor_position
      @parent_cursor_position ||= Thread.current[CURSOR_KEY]
    end

    def parent_cursor_position=(val)
      Thread.current[CURSOR_KEY] = val
    end

    def global_cursor_position
      parent_cursor_position.to_i + cursor_position
    end

    def remaining_width
      ResponsiveConsole.width - global_cursor_position
    end

    def cursor_indent
      ' ' * cursor_position
    end

    # This has minor issues with Rails 4 and always loading fresh copies of constants.
    # ActiveSupport::Dependencies.run_interlock would fix it, but is not available.
    def with_output_writer(skip_thread = output_writer.present?)
      return yield if skip_thread

      Thread.new(global_cursor_position) do |pos|
        self.parent_cursor_position = pos
        self.output_writer = StringIO.new
        yield
        output_writer.string
      end.join.value
    ensure
      self.output_writer = nil unless skip_thread
    end

    def capture_separately(&block)
      original_writer = output_writer
      with_output_writer(false, &block)
    ensure
      self.output_writer = original_writer
    end
  end
end

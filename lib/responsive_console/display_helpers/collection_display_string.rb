require_relative 'formattable'

module ResponsiveConsole
  module CollectionDisplayString
    def input
      element_map { |e| child_string(e) }
    end

    def child_string(object)
      Class.new(self.class).new(object)
    end

    def write_object(_element_format = nil, child_format = nil)
      self.default_format = child_format
      raw_elements = capture_separately do
        input.each_with_index do |e, i|
          i.zero? ? write(element_prefix) : write(temp_joiner)
          yield(e)
        end
      end
      write(prefix)
      write(post_process(raw_elements))
      write(suffix)
    end

    def post_process(string)
      joined = replace_temporary_joiner(string)
      # joined.gsub(/(?<=\n)/, cursor_indent)
      joined.gsub(/(?<=\n)/, cursor_indent).rstrip # #rstrip here not fully tested.
    end

    def temp_joiner
      singleton_class::TEMPORARY_JOINER
    end
  end
end

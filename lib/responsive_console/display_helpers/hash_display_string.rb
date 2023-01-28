require_relative 'collection_display_string'

module ResponsiveConsole
  module HashDisplayString
    include CollectionDisplayString

    TEMPORARY_JOINER = -"\u2341\n"

    def write_object(_element_format = nil, child_format = nil)
      super do |(k, v)|
        k.write_object(key_formats[:k], child_element_formats[:k])
        write(subjoiner)
        v.write_object(key_formats[:v], child_element_formats[:v])
      end
    end

    def element_map
      raw_input.transform_keys { |k| yield(k) }.transform_values { |v| yield(v) }
    end

    def replace_temporary_joiner(string)
      standard = string.gsub(temp_joiner, joiner)
      return standard if !wrapped?(string) && standard.size < remaining_width

      string.gsub(temp_joiner, newline_joiner)
    end

    def wrapped?(string)
      string.lines.size > raw_input.size
    end

    # A joiner that has been #rstrip'ed, but only up to the previous newline is removed.
    # This is to allow joiners with double newlines to correctly be displayed as empty lines.
    def newline_joiner
      *other, last = joiner.split(/\n/, -1)
      new_joiner = [*other, last.to_s.rstrip.presence].compact.join("\n")
      "#{new_joiner}\n"
    end
  end
end

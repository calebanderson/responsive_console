require_relative 'collection_display_string'

module ConsoleHelpers
  module ArrayDisplayString
    include CollectionDisplayString

    TEMPORARY_JOINER = -"\u2342 "

    def element_map
      raw_input.map { |k| yield(k) }
    end

    def write_object(_element_format = nil, child_format = nil)
      super do |e|
        e.write_object(key_formats[:e], child_element_formats[:e])
      end
    end

    def replace_temporary_joiner(string)
      wrapper_klass = joiner.include?("\n") ? Columnizer : SoftWrapper
      wrapper_klass.new(string, self).output
    end
  end
end

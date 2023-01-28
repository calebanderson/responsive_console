module ResponsiveConsole
  module ObjectDisplayString
    HANDLERS = {
      Numeric => ->(num) { num.round(5) },
      Time => :in_time_zone,
      DateTime => :in_time_zone,
      Module => :itself,
      BasicObject => ->(obj) { obj.try(:deep_dup) || obj.dup }
    }.freeze

    def write_object(element_format = '%<o>p', _child_format = nil)
      write Kernel.format(element_format.gsub(/<[a-z]>/, '<o>'), o: input)
    end

    def formatter; end

    def input
      @input ||= begin
        handler = HANDLERS.fetch(HANDLERS.keys.find { |k| raw_input.is_a?(k) }, :dup)
        instance_exec(raw_input, &handler)
      rescue TypeError
        raw_input
      end
    end
  end
end

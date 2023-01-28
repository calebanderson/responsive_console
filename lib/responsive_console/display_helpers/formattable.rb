module ResponsiveConsole
  module Formattable
    def self.included(base)
      base.extend(ClassMethods)
      base.delegate :prefix, :joiner, :subjoiner, :suffix, :key_formats, :child_element_formats, :element_prefix,
                    to: :formatter, allow_nil: true
    end

    DEFAULT = :default

    def formatter
      @formatter ||= formatter_class.new(format)
    end

    def format
      @format || default_format
    end

    def format=(val)
      return unless val.is_a?(String) || formatter_class::FORMATS.key?(val)

      @format = val
      @formatter = nil
    end

    def default_format=(val)
      self.class.default_formats.unshift(val)
      @formatter = nil
    end

    def default_format
      self.class.default_formats.find { |df| formatter_class::FORMATS.key?(df) }
    end

    def formatter_class
      case raw_input
      when Hash then HashFormatter
      when Enumerable then ArrayFormatter
      else raise NotImplementedError, "no known formatter for #{raw_input.class.inspect}"
      end
    end

    module ClassMethods
      attr_writer :default_formats

      # Using a collection that falls back to a universal key, so setting the default to a key that only makes sense
      # for a HashFormatter doesn't overwrite any other value set for, say, an ArrayFormatter.
      def default_formats
        @default_formats ||= [DEFAULT]
      end

      def inherited(subclass)
        super
        subclass.default_formats = default_formats.deep_dup
      end
    end
  end
end

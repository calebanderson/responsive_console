require_relative 'writable'

module ResponsiveConsole
  class Formatter
    include Writable

    NOT_KEY = /([^%]|%%)/.freeze

    attr_reader :format_string

    def initialize(format)
      @format_string =
        case format
        when String then format
        when Symbol then return initialize(self.class::FORMATS.fetch(format))
        end
      raise ArgumentError, "cannot interpret format string #{format_string.dump}" if parts.blank?

      detect_element_prefix
      standardize_element # initializes and populates a few lookup hashes
    end

    def standardize_element
      element.gsub(input_key_regex) do
        match = Regexp.last_match
        char = match[:key_char]&.downcase
        # Ruby pre 2.4.6 didn't have #match?
        # type = match[:key_char]&.match?(/[A-Z]/) ? :p : :s
        type = match[:key_char]&.match(/[A-Z]/) ? :p : :s
        child_element_formats[char] = match[:format]&.to_sym
        key_formats[char] = "%#{match[:args]}<#{char}>#{type}"
      end
    end

    # Detects and separates a portion of the prefix if it's part of each element (e.g. bullet points)
    # This can be done as part of the parts regex (see commit history), but it's more readable outside it.
    def detect_element_prefix
      # Using ' % ' as a joiner since it can't be contained in prefix or joiner
      element_prefix = "#{prefix} % #{joiner}"[/(\S.*)(?= % (?m:.*)\k<1>)/].to_s
      parts[:element_prefix] = element_prefix
      # Ruby pre 2.5.5 didn't have delete_suffix
      # parts[:prefix] = prefix.delete_suffix(element_prefix)
      parts[:prefix] = prefix.match(/#{element_prefix}\z/).pre_match
    end

    def child_element_formats
      @child_element_formats ||= {}.with_indifferent_access
    end

    def key_formats
      @key_formats ||= {}.with_indifferent_access
    end

    def parts
      # Ruby pre 2.4.6 didn't have MatchData#named_captures
      # @parts ||= format_string.match(parts_regex)&.named_captures&.symbolize_keys&.transform_values(&:to_s) || {}
      @parts ||= begin
        match_data = format_string.match(parts_regex)
        match_data.nil? ? {} : match_data.names.map { |n| [n.to_sym, match_data[n].to_s] }.to_h
      end
    end

    def key_char_regex
      /(?<key_char>[#{Array.wrap(self.class::ALLOWED_KEYS).join}])/i
    end

    def input_key_regex
      /%(?:(?<format>\w+)\$)?(?<args>[^a-z_%<]*?)#{key_char_regex}/i
    end

    def element_regex
      /(?<element>#{input_key_regex}(?:(?<subjoiner>.*?)#{input_key_regex})?)/m
    end

    def parts_regex
      /\A(?<prefix>(?<suffix>#{NOT_KEY}*))#{element_regex}(?<joiner>.*)\k<element>\g<suffix>\z/m
    end

    private

    def method_missing(method, *args, &block)
      parts&.fetch(method) { super }
    end

    def respond_to_missing?(method)
      parts&.key?(method) || super
    end
  end

  class ArrayFormatter < Formatter
    ALLOWED_KEYS = :e

    FORMATS = { # rubocop:disable Style/MutableConstant
      short: '[%E, %E]',
      medium: '[ %E | %E ]',
      long: "\u2022 %E\n\u2022 %E",
      methods: "\u2023 %E\n\u2023 %E",
      sub_methods: :methods,
      extra_long: :long,
      default: :long
    }
  end

  class HashFormatter < Formatter
    ALLOWED_KEYS = [:k, :v].freeze

    FORMATS = { # rubocop:disable Style/MutableConstant
      short: '{ %k: %V, %k: %V }',
      medium: :short,
      long: "{\n  %medium$k:  %medium$V,\n  %medium$k:  %medium$V\n}",
      methods: "%k:\n  %sub_methods$V\n%k:\n  %sub_methods$V",
      sub_methods: "%+10k  %V\n\n%+10k  %V",
      extra_long: "%k:\n  %V\n%k:\n  %V",
      default: :long
    }

    def ordered_keys
      @ordered_keys ||= ALLOWED_KEYS.dup.tap do |keys|
        keys.reverse! if key_char.downcase == ALLOWED_KEYS.first.to_s # key_char holds the last key character matched
      end
    end
  end
end

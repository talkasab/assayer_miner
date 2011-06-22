module ScenarioExtractor
  module Anonymizer
    NUM_DAY = '[0123]?\d'
    NUM_MONTH = '[01]?\d'
    SHORT_MONTH = %w{Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}.join('|')
    LONG_MONTH = %w{January February March April May June July August September October November December}.join('|')
    WORD_MONTH = "(?:#{LONG_MONTH}|#{SHORT_MONTH})"
    YEAR = '(?:19|20)?\d\d'
    SEPARATOR= '[- \/,]+'
    NOT_SEPARATOR= '[^- \/,]'
    MAYBE_YEAR = "(?:#{SEPARATOR}#{YEAR})?"

    DAY_WORD_MONTH_YEAR_RE = /#{NUM_DAY}#{SEPARATOR}#{WORD_MONTH}#{MAYBE_YEAR}/
    WORD_MONTH_DAY_YEAR_RE = /#{WORD_MONTH}#{SEPARATOR}#{NUM_DAY}#{MAYBE_YEAR}/
    NUM_MONTH_DAY_YEAR_RE = /#{NUM_MONTH}#{SEPARATOR}#{NUM_DAY}#{MAYBE_YEAR}/
    DAY_NUM_MONTH_YEAR_RE = /#{NUM_DAY}#{SEPARATOR}#{NUM_MONTH}#{MAYBE_YEAR}/

    LONG_NUMBER_RE = /[-\#\d]{4,}/
    A_ROUND_THOUSAND_RE = /^\d000$/

    class << self
      def anonymize(name, text)
        text = redact_name(name, text)
        text = redact_dates(text)
        redact_numbers(text)
      end

      def redact_name(name, text)
        names = name.split(/[ ,^]+/).map(&:strip).reject {|n| n.length < 2}
        names_re = /\b(?:#{names.join('|')})\b/i
        text.gsub(names_re) { |n| n.gsub(/[[:alnum:]]/, 'X') }
      end

      def redact_dates(text)
        regexes = [DAY_WORD_MONTH_YEAR_RE, WORD_MONTH_DAY_YEAR_RE, NUM_MONTH_DAY_YEAR_RE, DAY_NUM_MONTH_YEAR_RE]
        regexes.inject(text) { |fixed_text, re| fixed_text.gsub(re) { |n| n.gsub(/[[:alnum:]]/, '#') } }
      end

      def redact_numbers(text)
        text.gsub(LONG_NUMBER_RE) do |n|
          case n
          when A_ROUND_THOUSAND_RE then n  # Leave round thousands along
          else n.gsub(/[[:alnum:]]/, '#')
          end
        end
      end
    end
  end
end

require 'term/ansicolor'

module AppLog
  module StdIO
    class Logger < AppLog::Logger
      include Term::ANSIColor

      def initialize
        super(nil)
        @logdev = self
      end

      def close ; end
      def write(doc)
        color_map = { "DEBUG" => cyan, "INFO" => green, "WARN" => yellow, "ERROR" => magenta, "FATAL" => red, "UNKNOWN" => reset }
        STDERR.print color_map[doc[:severity]], doc[:formatted_message], reset
      end
    end
  end
end
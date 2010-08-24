require 'logger'

module AppLog
  class Logger < ::Logger
    attr_reader :loggers, :logdev

    def initialize(*loggers)
      super(nil)
      progname = ::File.basename(__FILE__)
      hostname = `hostname`.strip rescue '?'
      @progname = "#{progname}@#{hostname}"
      @formatter = DocFormatter.new
      @loggers = loggers
      @logdev = MultiIO.new(*loggers)
    end

    class DocFormatter < Logger::Formatter
      def call(severity, time, progname, msg)
        formatted_message = super
        { :severity => severity, :time => time, :progname => progname,  :message => msg2str(msg), :formatted_message => formatted_message }
      end
    end

    class MultiIO
      def initialize(*loggers)
        @loggers = loggers
      end

      # IO interface
      def close ; end
      def write(doc)
        @loggers.each { |l| l.logdev.write(doc) }
      end
    end
  end
end

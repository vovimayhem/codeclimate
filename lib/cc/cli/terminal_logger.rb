module CC
  module CLI
    class TerminalLogger
      attr_accessor :level

      def initialize
        self.level = ::Logger::INFO
      end

      def debug(message)
        write(Message.new(::Logger::DEBUG, message))
      end

      def info(message)
        write(Message.new(::Logger::INFO, message))
      end

      def warn(message)
        write(Message.new(::Logger::WARN, message))
      end

      def error(message)
        write(Message.new(::Logger::ERROR, message))
      end

      def fatal(message)
        write(Message.new(::Logger::FATAL, message))
      end

      private

      def write(message)
        if message.level >= level
          stream_for_level(message.level).puts(message.message)
        end
      end

      Message = Struct.new(:level, :message)

      def stream_for_level(level)
        if level >= ::Logger::ERROR
          $stderr
        else
          $stdout
        end
      end
    end
  end
end

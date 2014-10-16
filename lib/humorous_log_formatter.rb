# Copyright (c) 2014 Peter H. Boling of 9thBit LLC
# Released under the MIT license
# For Rails 3+
# Patterned after this LogFormatter:
#   https://github.com/QutBioacousticsResearchGroup/bioacoustic-workbench/blob/master/config/initializers/log_formatting.rb
# And some of this:
#   http://95.154.230.254/ip-1/encoded/Oi8vcGFzdGViaW4uY29tL1hxRU1keGRT
# Makes as much as possible constant values to not bog down GC and make it whip fast
require "humorous_log_formatter/version"

module HumorousLogFormatter
  class LogFormatter
    # TODO: For Rails 4, uncomment the line below
    #include ActiveSupport::TaggedLogging::Formatter
    SEVERITY_TO_TAG_MAP = {'DEBUG' => 'meh', 'INFO' => 'fyi', 'WARN' => 'hmm', 'ERROR' => 'wtf', 'FATAL' => 'omg', 'UNKNOWN' => '???'}
    SEVERITY_TO_COLOR_MAP = {'DEBUG' => '0;37', 'INFO' => '32', 'WARN' => '33', 'ERROR' => '31', 'FATAL' => '31', 'UNKNOWN' => '37'}
    USE_HUMOROUS_SEVERITIES = begin
      if ENV['LOG_HUMOR']
        ENV['LOG_HUMOR'] != 'false' # Default to true
      else
        Rails.env.development?
      end
    end
    USE_COLOR = begin
      if ENV['LOG_COLOR']
        ENV['LOG_COLOR'] != 'false' # Default to true
      else
        Rails.env.development?
      end
    end

    THIS_FILE_PATH = File.expand_path(".")

    FORMATTED_SEVERITY = USE_HUMOROUS_SEVERITIES ?
        lambda { |severity| sprintf("%-3s", "#{SEVERITY_TO_TAG_MAP[severity]}") } :
        lambda { |severity| sprintf("%-5s", "#{severity}") }

    FORMATTED_MESSAGE = if USE_COLOR
                          lambda { |severity, formatted_time, msg|
                            color = SEVERITY_TO_COLOR_MAP[severity]
                            "[\033[#{color}m#{formatted_time}\033[0m] [\033[#{color}m#{FORMATTED_SEVERITY.call(severity)}\033[0m] #{msg.strip}\n"
                          }
                        else
                          lambda { |severity, formatted_time, msg|
                            "[#{formatted_time}] [#{FORMATTED_SEVERITY.call(severity)}] #{msg.strip}\n"
                          }
                        end

    def exception_values(e)
      trace = e.backtrace.select { |x| !line.starts_with?(THIS_FILE_PATH) }
      trace = trace.map { |l| colorize_exception(l) } if USE_COLOR
      first = "\n" + trace.first + ": " + e.message + " (#{e.class})"
      rest = "\t" + trace[1..-1].join("\n\t")
      return first + "\n" + rest
    end

    def colorize_exception(line)
      "\033[01;32m#{line}\033[0m"
    end

    def call(severity, time, progname, msg)
      formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
      text = if msg.is_a? String
               msg
             elsif msg.is_a? Exception
               " --> Exception: " + exception_values(msg)
             else
               "!!!!! UNKNOWN TYPE: #{msg.class}" + msg.to_s
             end
      FORMATTED_MESSAGE.call(severity, formatted_time, text)
    end

    require "humorous_log_formatter/railtie"

  end
end




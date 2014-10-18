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

    # Make it work with Rails 4
    if defined?(Rails)
      if ::Rails::VERSION::MAJOR >= 4
        include ActiveSupport::TaggedLogging::Formatter
      end
    end

    SEVERITY_TO_TAG_MAP = {'DEBUG' => 'meh', 'INFO' => 'fyi', 'WARN' => 'hmm', 'ERROR' => 'wtf', 'FATAL' => 'omg', 'UNKNOWN' => '???'}
    SEVERITY_TO_COLOR_MAP = {'DEBUG' => '0;37', 'INFO' => '32', 'WARN' => '33', 'ERROR' => '31', 'FATAL' => '31', 'UNKNOWN' => '37'}
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S."
    SKIP_TIME = !Rails.env.development? # because heroku already prints the time, override if you use in prod and aren't on Heroku
    SUPER_TIME_PRECISION = 3
    SUPER_TIME_PRECISION_STOP_INDEX = SUPER_TIME_PRECISION - 1
    USE_SUPER_TIME = SUPER_TIME_PRECISION > 0
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
                            res = ''
                            res << "[\033[#{color}m#{formatted_time}\033[0m] " if formatted_time
                            res << "[\033[#{color}m#{FORMATTED_SEVERITY.call(severity)}\033[0m] #{msg.strip}\n"
                          }
                        else
                          lambda { |severity, formatted_time, msg|
                            res = ''
                            res << "[#{formatted_time}]" if formatted_time
                            res << "[#{FORMATTED_SEVERITY.call(severity)}] #{msg.strip}\n"
                          }
                        end

    def exception_values(e)
      trace = e.backtrace.select { |x| !line.starts_with?(THIS_FILE_PATH) }
      trace = trace.map { |l| colorize_exception(l) } if USE_COLOR
      first = "\n#{trace.first}: #{e.message} (#{e.class})"
      rest = "\t#{trace[1..-1].join("\n\t")}"
      "#{first}\n#{rest}"
    end

    def colorize_exception(line)
      "\033[01;32m#{line}\033[0m"
    end

    def call(severity, time, progname, msg)
      if SKIP_TIME
        formatted_time = nil
      else
        formatted_time = time.strftime(TIME_FORMAT)
        formatted_time << time.usec.to_s[0..(SUPER_TIME_PRECISION_STOP_INDEX)].rjust(SUPER_TIME_PRECISION) if USE_SUPER_TIME
      end
      text = if msg.is_a? String
               msg
             elsif msg.is_a? Exception
               "  --> Exception:#{exception_values(msg)}"
             else
               "!!!!! UNKNOWN TYPE: #{msg.class} #{msg.to_s}"
             end
      FORMATTED_MESSAGE.call(severity, formatted_time, text)
    end

    require "humorous_log_formatter/railtie"

  end
end




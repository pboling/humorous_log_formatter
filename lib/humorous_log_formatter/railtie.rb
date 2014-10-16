# Copyright (c) 2014 Peter H. Boling of 9thBit LLC
# Released under the MIT license
# For Rails 3+
module HumorousLogFormatter
  class Railtie < ::Rails::Railtie

    require 'humorous_log_formatter/ext/active_support_buffered_logger'

    config.after_initialize do
      Rails.logger.formatter = HumorousLogFormatter::LogFormatter.new
    end

  end
end

# Copyright (c) 2014 Peter H. Boling of 9thBit LLC
# Released under the MIT license
# For Rails 3+
class ActiveSupport::BufferedLogger
  # At some point after Rails 3 ActiveSupport::BufferedLogger began inheriting from Logger rather than Object.
  unless method_defined? :formatter=
    def formatter=(formatter)
      @log.formatter = formatter
    end
  end
end

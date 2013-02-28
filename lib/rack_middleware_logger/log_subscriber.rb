require 'active_support/log_subscriber'

module RackMiddlewareLogger
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime
      @runtime ||= 0
    end

    def self.runtime=(runtime)
      @runtime = runtime
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super
      @odd_or_even = false
    end

    def logging(event)
      duration = event.payload[:duration]

      self.class.runtime += duration

      log_threshold = event.payload[:log_threshold]
      return unless logger.debug? && duration > log_threshold

      middleware_name = event.payload[:middleware_name]

      name = 'Middleware (%.3fms)' % duration

      if odd?
        name = color(name, CYAN, true)
        middleware_name = color(middleware_name, nil, true)
      else
        name = color(name, MAGENTA, true)
      end

      debug "  #{name}  #{middleware_name}"
    end

    private
    def odd?
      @odd_or_even = !@odd_or_even
    end
  end
end

RackMiddlewareLogger::LogSubscriber.attach_to('logger.middleware.rack')

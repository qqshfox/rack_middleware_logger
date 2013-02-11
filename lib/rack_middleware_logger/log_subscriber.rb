require 'active_support/log_subscriber'

module RackMiddlewareLogger
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime
      @runtime
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
      @last_env_id = nil
      @last_duration = 0.0
      @odd_or_even = false
    end

    def start(event)
      middleware = event.payload[:middleware]
      env_id = event.payload[:env_id]
      duration = if @last_env_id && @last_env_id == env_id
                   event.duration - @last_duration
                 else
                   event.duration
                 end

      name = 'Middleware (%.3fms)' % duration
      middleware_name = middleware.class

      if odd?
        name = color(name, CYAN, true)
        middleware_name = color(middleware_name, nil, true)
      else
        name = color(name, MAGENTA, true)
      end

      debug "  #{name}  #{middleware_name}"
    ensure
      @last_env_id = env_id
      @last_duration = event.duration
      self.class.runtime = @last_duration
    end

    def test(event)
      debug event.payload[:message]
    end

    private
    def odd?
      @odd_or_even = !@odd_or_even
    end
  end
end

RackMiddlewareLogger::LogSubscriber.attach_to('logger.middleware.rack')

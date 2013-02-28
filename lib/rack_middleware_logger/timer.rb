require 'active_support/notifications'
require 'benchmark'
require 'active_support/core_ext/benchmark.rb'

module RackMiddlewareLogger
  class Timer

    DEFAULT_LOG_THRESHOLD = 0.1 # millisecond

    def self.log_threshold
      @log_threshold ||= DEFAULT_LOG_THRESHOLD
    end

    def self.log_threshold=(log_threshold)
      @log_threshold = log_threshold
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      result = nil

      runtime = Benchmark.ms { result = @app.call(env) }
      duration = if (last_runtime = env["RACK_MIDDLEWARE_LOGGER_RUNTIME"])
                   runtime - last_runtime
                 else
                   runtime
                 end
      env["RACK_MIDDLEWARE_LOGGER_RUNTIME"] = runtime

      raw_payload = {
        :middleware_name => @app.class.name,
        :duration => duration,
        :log_threshold => self.class.log_threshold,
      }

      ActiveSupport::Notifications.instrument('logging.logger.middleware.rack', raw_payload)

      result
    end

  end
end

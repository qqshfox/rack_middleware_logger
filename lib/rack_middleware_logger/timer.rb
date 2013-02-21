require 'active_support/notifications'
require 'benchmark'
require 'active_support/core_ext/benchmark.rb'

module RackMiddlewareLogger
  class Timer

    DEFAULT_OPTIONS = {
      :log_threshold => 0.1, # millisecond
    }

    def initialize(app, options={})
      @app = app
      @options = DEFAULT_OPTIONS.merge(options)
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
        :log_threshold => @options[:log_threshold],
      }

      ActiveSupport::Notifications.instrument('logging.logger.middleware.rack', raw_payload)

      result
    end

  end
end

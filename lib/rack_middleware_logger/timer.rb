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

      if duration > @options[:log_threshold]
        raw_payload = {
          :middleware_name => @app.class.name,
          :duration => duration,
        }

        ActiveSupport::Notifications.instrument('logging.logger.middleware.rack', raw_payload)
      end

      result
    end

  end
end

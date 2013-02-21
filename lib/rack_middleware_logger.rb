require 'rack_middleware_logger/version'
require 'rack_middleware_logger/log_subscriber'
require 'rack_middleware_logger/timer'
require 'rack_middleware_logger/rack_rails_logger' if defined?(RackRailsLogger)

module RackMiddlewareLogger
end

require 'action_dispatch/middleware/stack'

module ActionDispatch
  class MiddlewareStack

    class Middleware

      alias rack_middleware_logger_old_build build unless method_defined? :rack_middleware_logger_old_build
      def build(app)
        RackMiddlewareLogger::Timer.new(rack_middleware_logger_old_build(app))
      end

    end

    alias rack_middleware_logger_old_build build unless method_defined? :rack_middleware_logger_old_build
    def build(app = nil, &block)
      app ||= block
      raise "MiddlewareStack#build requires an app" unless app
      app = RackMiddlewareLogger::Timer.new(app)
      rack_middleware_logger_old_build app
    end

  end
end

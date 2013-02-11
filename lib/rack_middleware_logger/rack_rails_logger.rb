require 'rack_rails_logger/middleware'
require "rack_middleware_logger/railties/controller_runtime"

RackRailsLogger::Middleware.class_eval do
  include RackMiddlewareLogger::Railties::ControllerRuntime
end

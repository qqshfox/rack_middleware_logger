require 'rack_middleware_logger/railties/controller_runtime'
require 'rails/railtie'
require 'active_support/lazy_load_hooks'

module RackMiddlewareLogger
  class Railtie < Rails::Railtie
    initializer "rack_middleware.log_runtime" do |app|
      ActiveSupport.on_load(:action_controller) do
        include RackMiddlewareLogger::Railties::ControllerRuntime
      end
    end
  end
end

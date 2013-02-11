require 'rack_middleware_logger/version'
require 'rack_middleware_logger/log_subscriber'
require 'rack_middleware_logger/railtie' if defined?(Rails)
require 'rack_middleware_logger/rack_rails_logger' if defined?(RackRailsLogger)

require 'rack/builder'
require 'active_support/notifications'

module Rack
  class Builder
    alias old_use use unless method_defined? :old_use

    def use(middleware, *args, &block)
      middleware.class_eval do
        alias old_call call unless method_defined? :old_call
        def call(env)
          ActiveSupport::Notifications.instrument('start.logger.middleware.rack', :middleware => self, :env_id => env.__id__) do
            old_call(env)
          end
        end
      end
      old_use(middleware, *args, &block)
    end

  end
end

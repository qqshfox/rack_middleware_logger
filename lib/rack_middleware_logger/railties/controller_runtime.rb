require 'active_support/concern'
require 'active_support/core_ext/module/attr_internal'

module RackMiddlewareLogger
  module Railties
    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

      attr_internal :middleware_runtime

      def process_action(action, *args)
        # We also need to reset the runtime before each action
        # because of executions in middleware or in cases we are streaming
        # and it won't be cleaned up by the method below.
        RackMiddlewareLogger::LogSubscriber.reset_runtime
        super
      end

      def cleanup_view_runtime
        middleware_rt_before_render = RackMiddlewareLogger::LogSubscriber.reset_runtime
        runtime = super
        middleware_rt_after_render = RackMiddlewareLogger::LogSubscriber.reset_runtime
        self.middleware_runtime = middleware_rt_before_render + middleware_rt_after_render
        runtime - middleware_rt_after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:middleware_runtime] = (middleware_runtime || 0) + RackMiddlewareLogger::LogSubscriber.reset_runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages, middleware_runtime = super, payload[:middleware_runtime]
          messages << ("Middleware: %.1fms" % middleware_runtime.to_f) if middleware_runtime
          messages
        end
      end
    end
  end
end

require './lib/api/routing/request_builder'
require './lib/api/routing/routes'

module API
  module Routing
    class Dispatcher
      attr_reader :hiptest, :name, :args, :action, :resource_type

      def initialize(hiptest, name, args)
        @name = name
        @action, @resource_type = name.to_s.split('_', 2)
        raise ArgumentError.new("The method '#{name}' doesn't exist or isn't implemented yet") unless resource_type
        @hiptest = hiptest
        @args = args
      end

      def perform
        ensure_action_allowed!
        dispatch_request
      end

      def ensure_action_allowed!
        if !route.allowed?(verb)
          subject = route.segments.join('/')
          raise ArgumentError.new("Route '#{verb}' not found for route #{subject}")
        end
      end

      def route
        @route ||= API::Routing::Routes.lookup(resource_type) || raise(ArgumentError.new("Resource '#{resource_type}' is not found (looked up name = #{name})"))
      end

      def verb
        case action
        when 'get'
          resource_type.is_plural? ? 'index' : 'show'
        else
          action
        end
      end

      def request
        @request ||= RequestBuilder.new(route, verb, args)
      end

      def dispatch_request
        case action
        when 'get'
          hiptest.get(request.uri)
        when 'create'
          hiptest.post(request.uri, request.data)
        when 'update'
          hiptest.patch(request.uri, request.data)
        when 'delete'
          hiptest.delete(request.uri)
        end
      end
    end
  end
end

module API
  module Routing
    class RequestBuilder
      attr_reader :route, :verb, :args
      attr_reader :project_id, :data

      def initialize(route, verb, args)
        @route = route
        @verb = verb
        args = args.dup
        @project_id = args.shift
        @data = args.pop if has_data?
        @ids = [project_id] + args
      end

      def uri
        URI(build_url)
      end

      def build_url
        path = route.segments.zip(@ids).flatten.compact.join('/')
        API::Hiptest.base_url + "/" + path
      end

      private

      def has_data?
        ["create", "update"].include?(verb)
      end
    end
  end
end

require 'erb'

module API
  module Routing
    class RequestBuilder
      attr_reader :route, :args, :kwargs
      attr_reader :project_id, :data

      def initialize(route, *args, data: nil, **kwargs)
        @route = route
        args = args.flatten
        @project_id = args.shift
        @data = data
        @ids = [project_id] + args
        @kwargs = kwargs
      end

      def uri
        URI(build_url)
      end

      def path
        route.segments.zip(@ids).flatten.compact.join('/')
      end

      def query_parameters
        parameters = route.default_params.merge(kwargs)
        return if parameters.empty?
        key_value_pairs = parameters.to_a.map { |key, value| "#{key}=#{ERB::Util.url_encode(value)}" }
        key_value_pairs.join("&")
      end

      def build_url
        url = API::Hiptest.base_url + "/" + path
        url << "?#{query_parameters}" if query_parameters
        url
      end

      private
    end
  end
end

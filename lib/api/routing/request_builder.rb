require 'erb'

module API
  module Routing
    class RequestBuilder
      attr_reader :route, :ids, :data, :kwargs

      def initialize(route, *ids, data: nil, **kwargs)
        @route = route
        @ids = ids.flatten.map(&:to_s)
        @data = data
        @kwargs = kwargs
      end

      def uri
        URI(build_url)
      end

      def path
        route.segments.zip(ids).flatten.compact.join('/')
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
    end
  end
end

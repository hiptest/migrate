module API
  module Routing
    class RequestBuilder
      attr_reader :route, :verb, :args
      attr_reader :project_id, :grand_parent_id, :parent_id, :resource_id, :data

      def initialize(route, verb, args)
        @route = route
        @verb = verb
        args = args.dup
        @project_id = args.shift
        @data = args.pop if has_data?
        @resource_id = args.pop if has_resource_id?
        @parent_id = args.pop
        @grand_parent_id = args.pop
      end

      def uri
        URI(build_url)
      end

      def build_url
        resource_type = route.data_type
        grand_parent_type = route.grand_parent_type
        parent_type = route.parent_type
        url = API::Hiptest.base_url + "/projects/#{project_id}/"

        if grand_parent_id && grand_parent_type
          url << "#{grand_parent_type.underscore.pluralize}/#{grand_parent_id}/"
        end
        if parent_id && parent_type
          url << "#{parent_type.underscore.pluralize}/#{parent_id}/"
        end
        url << "#{resource_type.to_s.underscore.pluralize}"
        url << "/#{resource_id}" if has_resource_id?

        url
      end

      private

      def has_resource_id?
        ["show", "update", "delete"].include?(verb)
      end

      def has_data?
        ["create", "update"].include?(verb)
      end
    end
  end
end

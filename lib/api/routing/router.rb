require 'active_support/inflector'

require './lib/api/hiptest'
require './lib/utils/string'
require './lib/api/routing/projects'
require './lib/api/routing/scenarios'
require './lib/api/routing/test_snapshots'
require './lib/api/routing/routes'

module API
  module Routing
    include API::Routing::Routes

    def method_missing(name, *args)
      action, resource_type = name.to_s.split('_', 2)
      raise RuntimeError.new("The method '#{name}' doesn't exist or isn't implemented yet") unless resource_type
      route = API::Routing::Routes.lookup(resource_type) || raise(RuntimeError.new("Resource '#{resource_type}' is not found"))

      grand_parent_type = route.grand_parent_type
      parent_type = route.parent_type

      if !route.allowed?(action)
        subject = [grand_parent_type, parent_type, route.data_type].compact.join(' ')
        raise RuntimeError.new("Route '#{action}' not found for #{subject}")
      end

      case action
      when 'get'
        if resource_type.is_plural?
          dispatch_index(route, args: args)
        else
          dispatch_show(route, args: args)
        end
      when 'create'
        dispatch_create(route, args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      when 'update'
        dispatch_update(route, args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      when 'delete'
        dispatch_delete(route, args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      end
    end

    include API::Routing::Projects
    include API::Routing::Scenarios
    include API::Routing::TestSnapshots

    private

    def dispatch_index(route, args:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if route.grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
      elsif route.parent_type
        parent_id = args[1]
      end

      url = build_url(
        project_id: project_id,
        resource_type: route.data_type,
        parent_id: parent_id,
        parent_type: route.parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: route.grand_parent_type
      )

      get(URI(url))
    end

    def dispatch_show(route, args:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if route.grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
        resource_id = args[3]
      elsif route.parent_type
        parent_id = args[1]
        resource_id = args[2]
      else
        resource_id = args[1]
      end

      url = build_url(
        project_id: project_id,
        resource_type: route.data_type,
        parent_id: parent_id,
        parent_type: route.parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: route.grand_parent_type
      ) + "/#{resource_id}"

      get(URI(url))
    end

    def dispatch_create(route, args:, resource_type:, parent_type:, grand_parent_type:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
        data = args[3]
      elsif parent_type
        parent_id = args[1]
        data = args[2]
      else
        data = args[1]
      end

      url = build_url(
        project_id: project_id,
        resource_type: resource_type,
        parent_id: parent_id,
        parent_type: parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: grand_parent_type
      )

      post(URI(url), data)
    end

    def dispatch_update(route, args:, resource_type:, parent_type:, grand_parent_type:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
        resource_id = args[3]
        data = args[4]
      elsif parent_type
        parent_id = args[1]
        resource_id = args[2]
        data = args[3]
      else
        resource_id = args[1]
        data = args[2]
      end

      url = build_url(
        project_id: project_id,
        resource_type: resource_type,
        parent_id: parent_id,
        parent_type: parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: grand_parent_type
      ) + "/#{resource_id}"

      patch(URI(url), data)
    end

    def dispatch_delete(route, args:, resource_type:, parent_type:, grand_parent_type:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
        resource_id = args[3]
      elsif parent_type
        parent_id = args[1]
        resource_id = args[2]
      else
        resource_id = args[1]
      end

      url = build_url(
        project_id: project_id,
        resource_type: resource_type,
        parent_id: parent_id,
        parent_type: parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: grand_parent_type
      ) + "/#{resource_id}"

      delete(URI(url))
    end

    def build_url(project_id:, resource_type:, parent_id: nil, parent_type: nil, grand_parent_id: nil, grand_parent_type: nil)
      url = self.class.base_url + "/projects/#{project_id}/"

      if grand_parent_id && grand_parent_type
        url << "#{grand_parent_type.underscore.pluralize}/#{grand_parent_id}/"
      end
      if parent_id && parent_type
        url << "#{parent_type.underscore.pluralize}/#{parent_id}/"
      end
      resource_type = @@routes.dig(resource_type.singularize.to_sym, :key) || resource_type
      url << "#{resource_type.to_s.underscore.pluralize}"

      url
    end
  end
end

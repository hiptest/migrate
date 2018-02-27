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

    def magic_calculation(resource_type, parent_type: nil)
      parent_type = parent_type || @@routes.dig(resource_type.singularize.to_sym, :parent)
      grand_parent_type = @@routes.dig(parent_type, :parent)
      [grand_parent_type&.to_s, parent_type&.to_s]
    end

    def method_missing(name, *args)
      action, resource_type = name.to_s.split('_', 2)
      unless API::Routing::Routes.exists?(resource_type)
        if resource_type
          raise RuntimeError.new("Resource '#{resource_type}' is not found")
        else
          raise RuntimeError.new("The method '#{name}' doesn't exist or isn't implemented yet")
        end
      end

      grand_parent_type, parent_type = magic_calculation(resource_type, parent_type: parent_type)

      available_routes = @@routes.dig(resource_type.singularize.to_sym, :only)

      resource_name = @@routes.dig(resource_type.to_s.singularize.to_sym, :key)&.to_s || resource_type

      if !available_routes.include?(action.to_sym) && action.to_sym != :get
        subject = [grand_parent_type, parent_type, resource_name].compact.join(' ')
        raise RuntimeError.new("Route '#{action}' not found for #{subject}")
      end

      case action
      when 'get'
        dispatch_get(args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      when 'create'
        dispatch_create(args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      when 'update'
        dispatch_update(args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      when 'delete'
        dispatch_delete(args: args, resource_type: resource_type, parent_type: parent_type, grand_parent_type: grand_parent_type)
      end
    end

    include API::Routing::Projects
    include API::Routing::Scenarios
    include API::Routing::TestSnapshots

    private

    def dispatch_get(args:, resource_type:, parent_type:, grand_parent_type:)
      grand_parent_id = nil
      parent_id = nil

      project_id = args[0]

      if grand_parent_type
        grand_parent_id = args[1]
        parent_id = args[2]
      elsif parent_type
        parent_id = args[1]
      end

      url = build_url(
        project_id: project_id,
        resource_type: resource_type,
        parent_id: parent_id,
        parent_type: parent_type,
        grand_parent_id: grand_parent_id,
        grand_parent_type: grand_parent_type
      )

      if resource_type.is_plural?
        get(URI(url))
      else
        if grand_parent_type
          resource_id = args[3]
        elsif parent_type
          resource_id = args[2]
        else
          resource_id = args[1]
        end

        url << "/#{resource_id}"

        get(URI(url))
      end
    end

    def dispatch_create(args:, resource_type:, parent_type:, grand_parent_type:)
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

    def dispatch_update(args:, resource_type:, parent_type:, grand_parent_type:)
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

    def dispatch_delete(args:, resource_type:, parent_type:, grand_parent_type:)
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

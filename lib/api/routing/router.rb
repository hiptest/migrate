require 'active_support/inflector'

require './lib/api/hiptest'
require './lib/utils/string'
require './lib/api/routing/projects'
require './lib/api/routing/scenarios'
require './lib/api/routing/routes'

module API
  module Routing
    include API::Routing::Routes

    def method_missing(name, *args)
      if name.to_s.split('_', 3).length == 2
        action, resource_type = name.to_s.split('_', 2)
      else
        action, parent_type, resource_type = name.to_s.split('_', 3)
      end
      
      raise RuntimeError.new("The method '#{name}' doesn't exist or isn't implemented yet") if resource_type.nil?
      
      if parent_type
        available_routes = @@routes.dig(parent_type.singularize.to_sym, :resources, resource_type.singularize.to_sym, :only)
      else
        available_routes = @@routes.dig(resource_type.singularize.to_sym, :only)
      end
      
      if parent_type
        subject = "#{parent_type} #{resource_type}"
      else
        subject = "#{resource_type}"
      end
      
      raise RuntimeError.new("Resource '#{resource_type}' is not found") if available_routes.nil?
      raise RuntimeError.new("Route '#{action}' not found for #{subject}") if !available_routes.include?(action.to_sym) && action.to_sym != :get

      case action
      when 'get'
        dispatch_get(available_routes, args, parent_type, resource_type)
      when 'create'
        dispatch_create(available_routes, args, parent_type, resource_type)
      when 'update'
        dispatch_update(available_routes, args, parent_type, resource_type)
      when 'delete'
        dispatch_delete(available_routes, args, parent_type, resource_type)
      end
    end
    
    include API::Routing::Projects
    include API::Routing::Scenarios

    private
    
    def dispatch_get(available_routes, args, parent_type, resource_type)
      if resource_type.is_plural?
        if parent_type
          index(args[0], resource_type.singularize, args[1], parent_type.singularize)
        else
          index(args[0], resource_type.singularize)
        end
      else
        if parent_type
          show(args[0], args[2], resource_type, args[1], parent_type)
        else
          show(args[0], args[1], resource_type)
        end
      end
    end
    
    def dispatch_create(available_routes, args, parent_type, resource_type)
      if parent_type
        create(args[0], args[2], resource_type, args[1], parent_type)
      else
        create(args[0], args[1], resource_type)
      end
    end
    
    def dispatch_update(available_routes, args, parent_type, resource_type)
      if parent_type
        update(args[0], args[2], args[3], resource_type, args[1], parent_type)
      else
        update(args[0], args[1], args[2], resource_type)
      end
    end
    
    def dispatch_delete(available_routes, args, parent_type, resource_type)
      if parent_type
        destroy(args[0], args[2], resource_type, args[1], parent_type)
      else
        destroy(args[0], args[1], resource_type)
      end
    end
    
    
    
    def index(project_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "/projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}"
      get(URI(url))
    end
    
    def show(project_id, resource_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "/projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      get(URI(url))
    end

    def create(project_id, data, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "/projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}"
      post(URI(url), data)
    end

    def update(project_id, resource_id, data, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "/projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      patch(URI(url), data)
    end

    def destroy(project_id, resource_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "/projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      delete(URI(url))
    end
  end
end
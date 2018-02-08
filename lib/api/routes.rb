require 'active_support/inflector'

require './lib/api/api'
require './lib/utils/string'
require './lib/api/routes/projects'

module API
  module Routes
    @@routes = {
      scenario: {
        only: [:show, :index, :create, :update, :delete],
        resources: {
          parameter: {
            only: [:show, :index, :create, :update, :delete]
          },
          dataset: {
            only: [:show, :index, :create, :update, :delete]
          },
          tag: {
            only: [:show, :index, :create, :update, :delete]
          }
        }
      },
      folder: {
        only: [:show, :index, :create, :update, :delete],
        resources: {
          tag: {
            only: [:index]
          }
        }
      }
    }

    def method_missing(name, *args)
      if name.to_s.split('_', 3).length == 2
        action, resource_type = name.to_s.split('_', 2)
      else
        action, parent_type, resource_type = name.to_s.split('_', 3)
      end
      
      raise "#{name} doesn't exist or isn't yet implemented" if resource_type.nil?
      
      if parent_type
        available_routes = @@routes.dig(parent_type.singularize.to_sym, :resources, resource_type.singularize.to_sym, :only)
      else
        available_routes = @@routes.dig(resource_type.singularize.to_sym, :only)
      end
      
      raise "Route #{action} not found for #{resource_type}" if available_routes.nil?

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
    
    include API::Routes::Projects

    private
    
    def dispatch_get(available_routes, args, parent_type, resource_type)
      if resource_type.is_plural?
        raise "Route #{action} not found for #{resource_type}" unless available_routes.include?(:index)
        if parent_type
          index(args[0], resource_type.singularize, args[1], parent_type.singularize)
        else
          index(args[0], resource_type.singularize)
        end
      else
        raise "Route #{action} not found for #{resource_type}" unless available_routes.include?(:show)
        if parent_type
          show(args[0], args[2], resource_type, args[1], parent_type)
        else
          show(args[0], args[1], resource_type)
        end
      end
    end
    
    def dispatch_create(available_routes, args, parent_type, resource_type)
      raise "Route #{action} not found for #{resource_type}" unless available_routes.include?(:create)
      if parent_type
        create(args[0], args[2], resource_type, args[1], parent_type)
      else
        create(args[0], args[1], resource_type)
      end
    end
    
    def dispatch_update(available_routes, args, parent_type, resource_type)
      raise "Route #{action} not found for #{resource_type}" unless available_routes.include?(:update)
      if parent_type
        update(args[0], args[2], args[3], resource_type, args[1], parent_type)
      else
        update(args[0], args[1], args[2], resource_type)
      end
    end
    
    def dispatch_delete(available_routes, args, parent_type, resource_type)
      raise "Route #{action} not found for #{resource_type}" unless available_routes.include?(:delete)
      if parent_type
        destroy(args[0], args[2], resource_type, args[1], parent_type)
      else
        destroy(args[0], args[1], resource_type)
      end
    end
    
    
    
    def index(project_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}"
      get(URI(url))
    end
    
    def show(project_id, resource_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      get(URI(url))
    end

    def create(project_id, data, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}"
      post(URI(url), data.to_json)
    end

    def update(project_id, resource_id, data, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      patch(URI(url), data.to_json)
    end

    def destroy(project_id, resource_id, resource_type, parent_id = nil, parent_type = nil)
      url = self.class.base_url + "projects/#{project_id}/"
      if parent_id && parent_type
        url += "#{parent_type.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.pluralize}/#{resource_id}"
      delete(URI(url))
    end
  end
end
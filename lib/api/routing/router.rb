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
      params = name.to_s.split('_')
      
      case params.count
      when 4
        action, grand_parent_type, parent_type, resource_type = params
      when 3
        action, parent_type, resource_type = params
      when 2
        action, resource_type = params
      when 1
        raise RuntimeError.new("The method '#{name}' doesn't exist or isn't implemented yet")
      else
        raise RuntimeError.new('Resource nested too deeply')
      end
      
      if grand_parent_type
        available_routes = @@routes.dig(grand_parent_type.singularize.to_sym, :resources, parent_type.singularize.to_sym, :resources, resource_type.singularize.to_sym, :only)
      elsif parent_type
        available_routes = @@routes.dig(parent_type.singularize.to_sym, :resources, resource_type.singularize.to_sym, :only)
      else
        available_routes = @@routes.dig(resource_type.singularize.to_sym, :only)
      end
      
      if grand_parent_type
        subject = "#{grand_parent_type} #{parent_type} #{resource_type}"
      elsif parent_type
        subject = "#{parent_type} #{resource_type}"
      else
        subject = "#{resource_type}"
      end
      
      raise RuntimeError.new("Resource '#{resource_type}' is not found") if available_routes.nil?
      raise RuntimeError.new("Route '#{action}' not found for #{subject}") if !available_routes.include?(action.to_sym) && action.to_sym != :get

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
    
    def dependencies_of(resource_type)
      @@dependencies_graph.dig(resource_type.singularize.to_sym)
    end

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
        
        url += "/#{resource_id}"
        
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
        url += "#{grand_parent_type.underscore.pluralize}/#{grand_parent_id}/"
      end
      if parent_id && parent_type
        url += "#{parent_type.underscore.pluralize}/#{parent_id}/"
      end
      url += "#{resource_type.underscore.pluralize}"
      
      url
    end
  end
end
module API::Routing::Routes

  class Route
    attr_reader :name, :only, :parent_type, :data_type
    
    def initialize(name:, only:, parent_type: nil, data_type: nil)
      @name = name
      @only = only
      @parent_type = parent_type
      @data_type = data_type || name
    end

    def allowed?(verb)
      only.include?(verb.to_sym)
    end

    def parent_route
      API::Routing::Routes.lookup(parent_type)
    end

    def level
      if parent_route
        1 + parent_route.level
      else
        1
      end
    end

    def grand_parent_type
      parent_route&.parent_type
    end
  end

  ROUTES = [
    Route.new(
      name: "actionword",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "parameter",
      parent_type: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "dataset",
      parent_type: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "folder",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "testRun",
      only: [:show, :index, :create],
    ),
    Route.new(
      name: "testSnapshot",
      parent_type: "testRun",
      only: [:show, :index],
    ),
    Route.new(
      name: "testResult",
      parent_type: "testSnapshot",
      only: [:create],
    ),
    Route.new(
      name: "scenarioTag",
      data_type: "tag",
      parent_type: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "folderTag",
      data_type: "tag",
      parent_type: "folder",
      only: [:index],
    ),
  ]

  @@routes_index = {}
  ROUTES.each do |route|
    @@routes_index[route.name.to_s.singularize] = route
    @@routes_index[route.name.to_s.pluralize] = route
  end

  class << self
    def lookup(route_name)
      @@routes_index[route_name]
    end

    def level(route_name)
      route = lookup(route_name)
      route ? route.level : 0
    end

    def exists?(route_name)
      !!lookup(route_name)
    end
  end
end

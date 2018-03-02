module API::Routing::Routes

  class NullRoute
    def level
      -1
    end

    def segments
      []
    end

    def data_type
      nil
    end
  end

  class Route
    attr_reader :name, :only, :parent, :data_type

    def initialize(name:, only:, parent: nil, data_type: nil)
      @name = name
      @only = only
      @parent = parent
      @data_type = data_type || name
    end

    def allowed?(verb)
      only.include?(verb.to_sym)
    end

    def parent_route
      API::Routing::Routes.lookup(parent) || NullRoute.new
    end

    def level
      1 + parent_route.level
    end

    def segments
      parent_route.segments << data_type.underscore.pluralize
    end
  end

  ROUTES = [
    Route.new(
      name: "project",
      only: [:show, :index],
    ),
    Route.new(
      name: "actionword",
      parent: "project",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "scenario",
      parent: "project",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "parameter",
      parent: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "dataset",
      parent: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "folder",
      parent: "project",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "testRun",
      parent: "project",
      only: [:show, :index, :create],
    ),
    Route.new(
      name: "testSnapshot",
      parent: "testRun",
      only: [:show, :index],
    ),
    Route.new(
      name: "testResult",
      parent: "testSnapshot",
      only: [:create],
    ),
    Route.new(
      name: "scenarioTag",
      data_type: "tag",
      parent: "scenario",
      only: [:show, :index, :create, :update, :delete],
    ),
    Route.new(
      name: "folderTag",
      data_type: "tag",
      parent: "folder",
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

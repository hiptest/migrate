module API::Routing::Routes

  class Route
    attr_reader :name, :only, :parent_type, :data_type
    def initialize(name:, only:, parent_type: nil, data_type: nil)
      @name = name
      @only = only
      @parent_type = parent_type
      @data_type = data_type || name
    end

    def allowed?(action)
      if action.to_sym == :get
        only.include?(:show) || only.include?(:index)
      else
        only.include?(action.to_sym)
      end
    end

    def parent_route
      API::Routing::Routes.lookup(parent_type)
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

  @@routes = {}
  @@routes_index = {}
  ROUTES.each do |route|
    route_info = {
      parent: route.parent_type,
      only: route.only,
      key: route.data_type,
    }
    @@routes[route.name.to_sym] = route_info
    @@routes_index[route.name.to_s.singularize] = route
    @@routes_index[route.name.to_s.pluralize] = route
    @@routes_index[route.name.to_sym] = route
  end

  class << self
    def lookup(route_name)
      @@routes_index[route_name]
    end

    def level(route_name)
      return 0 unless route_name
      route_name = route_name.to_s.split('_').last.singularize.to_sym
      if @@routes.key?(route_name)
        1 + level(@@routes.dig(route_name, :parent))
      else
        0
      end
    end

    def exists?(route_name)
      if route_name
        @@routes.key?(route_name.to_s.singularize.to_sym)
      else
        false
      end
    end
  end
end

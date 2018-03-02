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
    attr_reader :name, :only, :parent, :data_type, :default_params

    def initialize(name:, only:, parent: nil, data_type: nil, default_params: {})
      @name = name
      @only = only
      @parent = parent
      @data_type = data_type || name
      @default_params = default_params
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
      name: "root_scenarios_folder",
      only: [:show],
      data_type: "project",
      default_params: {
        include: 'scenarios-folder',
      }
    ),
    Route.new(
      name: "actionword",
      only: [:show, :index, :create, :update, :delete],
      parent: "project",
    ),
    Route.new(
      name: "scenario",
      only: [:show, :index, :create, :update, :delete],
      parent: "project",
    ),
    Route.new(
      name: "scenarios_by_jira_id",
      only: [:find],
      parent: "scenario",
      data_type: "find_by_tags",
      default_params: {
        key: 'JIRA',
      }
    ),
    Route.new(
      name: "parameter",
      only: [:show, :index, :create, :update, :delete],
      parent: "scenario",
    ),
    Route.new(
      name: "dataset",
      only: [:show, :index, :create, :update, :delete],
      parent: "scenario",
    ),
    Route.new(
      name: "folder",
      only: [:show, :index, :create, :update, :delete],
      parent: "project",
    ),
    Route.new(
      name: "testRun",
      only: [:show, :index, :create],
      parent: "project",
    ),
    Route.new(
      name: "testSnapshot",
      only: [:show, :index],
      parent: "testRun",
    ),
    Route.new(
      name: "testResult",
      only: [:create],
      parent: "testSnapshot",
    ),
    Route.new(
      name: "scenarioTag",
      only: [:show, :index, :create, :update, :delete],
      parent: "scenario",
      data_type: "tag",
    ),
    Route.new(
      name: "folderTag",
      only: [:index],
      parent: "folder",
      data_type: "tag",
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

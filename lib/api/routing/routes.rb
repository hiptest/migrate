module API::Routing::Routes

  class NullRoute
    def level
      -1
    end

    def segments
      []
    end

    def segment_name
      nil
    end
  end

  class Route
    attr_reader :name, :only, :parent, :segment_name, :default_params

    def initialize(name:, only:, parent: nil, segment_name: nil, default_params: {})
      @name = name
      @only = only
      @parent = parent
      @segment_name = segment_name || name.underscore
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
      parent_route.segments << segment_name.pluralize
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
      segment_name: "project",
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
      segment_name: "find_by_tags",
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
      segment_name: "tag",
    ),
    Route.new(
      name: "folderTag",
      only: [:index],
      parent: "folder",
      segment_name: "tag",
    ),
  ]

  @@routes_index = {}
  ROUTES.each do |route|
    @@routes_index[route.name.singularize] = route
    @@routes_index[route.name.pluralize] = route
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

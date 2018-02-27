module API::Routing::Routes
  @@routes = {
    actionword: {
      only: [:show, :index, :create, :update, :delete],
    },
    scenario: {
      only: [:show, :index, :create, :update, :delete],
    },
    parameter: {
      parent: :scenario,
      only: [:show, :index, :create, :update, :delete],
    },
    dataset: {
      parent: :scenario,
      only: [:show, :index, :create, :update, :delete],
    },
    folder: {
      only: [:show, :index, :create, :update, :delete],
    },
    testRun: {
      only: [:show, :index, :create],
    },
    testSnapshot: {
      parent: :testRun,
      only: [:show, :index],
    },
    testResult: {
      parent: :testSnapshot,
      only: [:create],
    },
    scenarioTag: {
      key: :tag,
      parent: :scenario,
      only: [:show, :index, :create, :update, :delete],
    },
    folderTag: {
      key: :tag,
      parent: :folder,
      only: [:index],
    },
  }
  class << self
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

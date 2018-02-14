module API::Routing::Routes
  @@routes = {
    actionword: {
      only: [:show, :index, :create, :update, :delete]
    },
    
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
    },
    
    'test-run': {
      only: [:show, :index, :create]
    }
  }
end
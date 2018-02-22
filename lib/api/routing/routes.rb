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
    
    testRun: {
      only: [:show, :index, :create],
      resources: {
        testSnapshot: {
          only: [:show, :index],
          resources: {
            testResult: {
              only: [:create]
            }
          }
        }
      }
    }
  }
end
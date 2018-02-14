require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Scenarios' do
  it_behaves_like 'an API CRUD resource' do
    let(:resource_type_main) { "scenario" }
    
    let(:index_route_main){ "https://hiptest.net/api/projects/1/scenarios" }
    let(:index_response_data_main){
      {
        data: [
          {
            type: "scenarios",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }, {
            type: "scenarios",
            id: "2",
            attributes: {
                name: "Goodbye Marylou"
            }
          }
        ]
      }
    }
    
    let(:show_route_main){ "https://hiptest.net/api/projects/1/scenarios/1" }
    let(:show_response_data_main){
      {
        data: {
            type: "scenarios",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }
        }
    }
    
    let(:create_data_main){
      {
        data: {
          attributes: {
            name: "I've got the power"
          }
        }
      }
    }
    let(:create_response_data_main){
      {
        data: {
          type: "scenarios",
          id: "1",
          attributes: {
              name: "I've got the power"
          }
        }
      }
    }
    
    let(:update_data_main){
      {
        data: {
          type: "scenarios",
          id: "1",
          attributes: {
            name: "I've got the power"
          }
        }
      }
    }
  end
end
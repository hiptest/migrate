require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Parameters' do
  it_behaves_like 'an API CRUD resource' do
    let(:resource_type_main) { "scenario_parameter" }
    
    let(:index_route_main){ "https://hiptest.net/api/projects/1/scenarios/1/parameters" }
    let(:index_response_data_main){
      {
        data: [
          {
            type: "parameters",
            id: "1",
            attributes: {
                name: "Invisibility"
            }
          }, {
            type: "parameters",
            id: "2",
            attributes: {
                name: "Strength"
            }
          }
        ]
      }
    }
    
    let(:show_route_main){ "https://hiptest.net/api/projects/1/scenarios/1/parameters/1" }
    let(:show_response_data_main){
      {
        data: {
            type: "parameters",
            id: "1",
            attributes: {
                name: "Invisibility"
            }
          }
        }
    }
    
    let(:create_data_main){
      {
        data: {
          attributes: {
            name: "Invisibility"
          }
        }
      }
    }
    let(:create_response_data_main){
      {
        data: {
            type: "parameters",
            id: "1",
            attributes: {
                name: "Invisibility"
            }
          }
        }
    }
    
    let(:update_data_main){
      {
        data: {
          type: "parameters",
          id: "1",
          attributes: {
            name: "Invulnerability"
          }
        }
      }
    }
  end
end
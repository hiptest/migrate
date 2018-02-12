require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Parameters' do
  it_behaves_like 'an api resource model' do
    let(:resource_type) { "scenario_parameter" }
    
    let(:index_route){ "https://hiptest.net/api/projects/1/scenarios/1/parameters" }
    let(:index_response_data){
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
    
    let(:show_route){ "https://hiptest.net/api/projects/1/scenarios/1/parameters/1" }
    let(:show_response_data){
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
    
    let(:create_data){
      {
        data: {
          attributes: {
            name: "Invisibility"
          }
        }
      }
    }
    let(:create_response_data){
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
    
    let(:update_data){
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
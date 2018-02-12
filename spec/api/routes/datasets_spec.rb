require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API datasets' do
  it_behaves_like 'an api resource model' do
    let(:resource_type) { 'scenario_dataset' }
    
    let(:index_route){ "https://hiptest.net/api/projects/1/scenarios/1/datasets" }
    let(:index_response_data){
      {
        data: [
          {
            type: "datasets",
            id: "1",
            attributes: {
                name: "Super Power"
            }
          }, {
            type: "datasets",
            id: "2",
            attributes: {
                name: "Weakness"
            }
          }
        ]
      }
    }
    
    let(:show_route){ "https://hiptest.net/api/projects/1/scenarios/1/datasets/1" }
    let(:show_response_data){
      {
        data: {
            type: "datasets",
            id: "1",
            attributes: {
                name: "Super Power"
            }
          }
        }
    }
    
    let(:create_data){
      {
        data: {
          attributes: {
            name: "Super Power"
          }
        }
      }
    }
    let(:create_response_data){
      {
        data: {
            type: "datasets",
            id: "1",
            attributes: {
                name: "Super Power"
            }
          }
        }
    }
    
    let(:update_data){
      {
       data: {
         type: "datasets",
         id: "1",
         attributes: {
           name: "Strength"
         }
       }
     }
    }
  end
end
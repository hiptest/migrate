require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Scenarios' do
  it_behaves_like 'an api resource model' do
    let(:resource_type) { "actionword" }
    
    let(:index_route){ "https://hiptest.net/api/projects/1/actionwords" }
    let(:index_response_data){
      {
        data: [
          {
            type: "actionwords",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }, {
            type: "actionwords",
            id: "2",
            attributes: {
                name: "Goodbye Marylou"
            }
          }
        ]
      }
    }
    
    let(:show_route){ "https://hiptest.net/api/projects/1/actionwords/1" }
    let(:show_response_data){
      {
        data: {
            type: "actionwords",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }
        }
    }
    
    let(:create_data){
      {
        data: {
          attributes: {
            name: "I've got the power"
          }
        }
      }
    }
    let(:create_response_data){
      {
        data: {
          type: "actionwords",
          id: "1",
          attributes: {
              name: "I've got the power"
          }
        }
      }
    }
    
    let(:update_data){
      {
        data: {
          type: "actionwords",
          id: "1",
          attributes: {
            name: "I've got the power"
          }
        }
      }
    }
  end
end
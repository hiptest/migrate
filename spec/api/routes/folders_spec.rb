require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Folders' do
  it_behaves_like 'an api resource model' do
    let(:resource_type) { "folder" }
    
    let(:index_route){ "https://hiptest.net/api/projects/1/folders" }
    let(:index_response_data){
      {
        data: [
          {
            type: "folders",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }, {
            type: "folders",
            id: "2",
            attributes: {
                name: "Goodbye Marylou"
            }
          }
        ]
      }
    }
    
    let(:show_route){ "https://hiptest.net/api/projects/1/folders/1" }
    let(:show_response_data){
      {
        data: {
            type: "folders",
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
            type: "folders",
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
          type: "folders",
          id: "1",
          attributes: {
            name: "I've got the power"
          }
        }
      }
    }
  end
end
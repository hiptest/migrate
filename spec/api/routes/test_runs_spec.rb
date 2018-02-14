require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Test runs' do
  let(:resource_type_main) { "test-run" }
  
  let(:index_route_main) { "https://hiptest.net/api/projects/1/test-runs" }
  let(:index_response_data_main) {
    {
      data: [
        {
          type: "test-runs",
          id: "1",
          attributes: {
              name: "Stark"
          }
        }, {
          type: "test-runs",
          id: "2",
          attributes: {
              name: "Lannister"
          }
        }
      ]
    }
  }
  
  let(:show_route_main) { "https://hiptest.net/api/projects/1/test-runs/1" }
  let(:show_response_data_main ) {
    {
      data: {
        type: "test-runs",
        id: "1",
        attributes: {
          name: "Stark"
        }
      }
    }
  }
  
  let(:create_data_main) {
    {
      data: {
        attributes: {
          name: "Stark"
        }
      }
    }
  }
  
  let(:create_response_data_main) {
    {
      data: {
        type: "test-runs",
        id: "1",
        attributes: {
            name: "Stark"
        }
      }
    }
  }
  
  it_behaves_like 'an API readable resource' do
    let(:resource_type) { resource_type_main }
    
    let(:index_route) { index_route_main }
    let(:index_response_data) { index_response_data_main }
    
    let(:show_route) { show_route_main }
    let(:show_response_data) { show_response_data_main }
  end
  
  
  
  it_behaves_like 'an API creatable resource' do
    let(:resource_type) { resource_type_main }
    
    let(:route) { index_route_main }
    let(:data) { create_data_main }
    let(:response_data) { create_response_data_main }
  end
end
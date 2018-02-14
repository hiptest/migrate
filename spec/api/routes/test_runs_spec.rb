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
            name: "Stark",
            description: "",
            statuses: {
              passed: 3,
              failed: 1,
              retest: 4,
              undefined: 1,
              blocked: 5,
              skipped: 9,
              wip: 0
            }
          }
        }, {
          type: "test-runs",
          id: "2",
          attributes: {
            name: "Lannister",
            description: "",
            statuses: {
              passed: 3,
              failed: 1,
              retest: 4,
              undefined: 1,
              blocked: 5,
              skipped: 9,
              wip: 0
            }
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
          name: "Stark",
          description: "",
          statuses: {
            passed: 3,
            failed: 1,
            retest: 4,
            undefined: 1,
            blocked: 5,
            skipped: 9,
            wip: 0
          }
        }
      }
    }
  }
  
  let(:create_data_main) {
    {
      data: {
        attributes: {
          name: "Stark",
          description: ""
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
          name: "Stark",
          description: "",
          statuses: {
            passed: 0,
            failed: 0,
            retest: 0,
            undefined: 314,
            blocked: 0,
            skipped: 0,
            wip: 0
          }
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
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
  
  let!(:api){
    API::Hiptest.configure do |config|
      config.access_token = "access_token"
      config.client = "client"
      config.uid = "uid@uid.uid"
    end
    
    API::Hiptest.new
  }
  
  let(:auth_headers) {
    {
      "accept": "application/vnd.api+json; version=1",
      "access-token": API::Hiptest.configuration.access_token,
      "client": API::Hiptest.configuration.client,
      "uid": API::Hiptest.configuration.uid
    }
  }
  
  let(:scenario) {
    Models::Scenario.new("I've got the power")
  }
  
  it "#find_scenario_by_jira_id" do
    stub = stub_request(:get, URI("https://hiptest.net/api/projects/1/scenarios/find_by_tags?key=JIRA&value=bidibou"))
      .with(headers: auth_headers)
      .to_return(status: 200, body: {
        data: [
          {
            type: "scenarios",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }
        ]
      }.to_json)
    
    res = api.find_scenario_by_jira_id(project_id: 1, jira_id: "bidibou")
    
    expect(stub).to have_been_requested
    expect(res.dig('data')).not_to be_empty
  end
end
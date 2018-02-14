require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Projects' do
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
  
  before do
    @project_id = 1
  end
  
  it_behaves_like 'an API readable resource' do
    let(:resource_type) { 'project' }
    let(:resource_nested_level) { 0 }
    
    let(:index_route) { "https://hiptest.net/api/projects" }
    let(:index_response_data) {
      {
        data: [
          {
            type: "projects",
            id: "1",
            attributes: {
              name: "And the Philosopher's Stone"
            }
          },
          {
            type: "projects",
            id: "2",
            attributes: {
              name: "And the Chamber of Secrets"
            }
          }
        ]
      }
    }
    
    let(:show_route) { "https://hiptest.net/api/projects/#{@project_id}" }
    let(:show_response_data) {
      {
        data: {
          type: "projects",
          id: "1",
          attributes: {
            name: "And the Philosopher's Stone"
          }
        }
      }
    }
  end
  
  it "#GET root scenarios folder" do
    stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}")
      .with(headers: auth_headers, query: { "include": "scenarios-folder" })
      .to_return(status: 200, body: {
        data: {
          type: "projects",
          id: "1",
          attributes: {
            name: "And the Philosopher's Stone"
          }
        },
        "included": [
          {
            type: "folders",
            id: "1",
            attributes: {
              name: "Test"
            }
          }
        ]
      }.to_json)
    
    projects_data = api.get_root_scenarios_folder(1)
    expect(stub).to have_been_requested
    expect(projects_data.dig('data')).not_to be_empty
    expect(projects_data.dig('included').any?).to be_truthy
  end
end
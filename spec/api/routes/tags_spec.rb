require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API Tags' do
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
    @actionword_id = 11
    @scenario_id = 1
    @folder_id = 1211
    @tag_id = 111221
  end
  
  context "about scenarios" do
    it "#GET scenario tags" do
      stub = stub_request(:get, "https://hiptest.net/api/projects/1/scenarios/1/tags")
        .with(headers: auth_headers)
        .to_return(status: 200, body: {
          data: [
            {
              type: "tags",
              id: "1",
              attributes: {
                key: "Priority",
                value: "low"
              }
            },
            {
              type: "tags",
              id: "2",
              attributes: {
                key: "Sprint",
                value: "1"
              }
            }
          ]
        }.to_json)
      
      projects_data = api.get_scenario_tags(@project_id, @scenario_id)
      expect(stub).to have_been_requested
      expect(projects_data.dig('data').any?).to be_truthy
    end
    
    it_behaves_like 'an API creatable resource' do
      let(:resource_type) { 'scenario_tag' }
      let(:route) { "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags" }
      let(:data) {
        {
          data: {
            attributes: {
              key: "Priority",
              value: "low"
            }
          }
        }
      }
      let(:response_data) {
        {
          data: {
              type: "tags",
              id: "1",
              attributes: {
                key: "Priority",
                value: "low"
              }
            }
          }
      }
    end
    
    it_behaves_like 'an API updatable resource' do
      let(:resource_type) { 'scenario_tag' }
      let(:route) { "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags/1" }
      let(:data) {
        {
          data: {
            type: "tags",
            id: "1",
            attributes: {
              key: "Priority",
              value: "low"
            }
          }
        }
      }
      let(:response_data) { data }
    end
    
    it_behaves_like 'an API deletable resource' do
      let(:resource_type) { 'scenario_tag' }
      let(:route) { "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags/1" }
    end
  end
  
  context "about folders" do
    it "#GET folder tags" do
      stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/folders/#{@folder_id}/tags")
        .with(headers: auth_headers)
        .to_return(status: 200, body: {
          data: [
            {
              type: "tags",
              id: "1",
              attributes: {
                key: "Priority",
                value: "low"
              }
            },
            {
              type: "tags",
              id: "2",
              attributes: {
                key: "Sprint",
                value: "1"
              }
            }
          ]
        }.to_json)
      
      projects_data = api.get_folder_tags(@project_id, @folder_id)
      expect(stub).to have_been_requested
      expect(projects_data.dig('data').any?).to be_truthy
    end
  end
end
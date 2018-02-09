require './lib/api/hiptest'
require 'webmock/rspec'

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
    @scenario_id = 21
    @folder_id = 1211
    @tag_id = 111221
  end
  
  context "about scenarios" do
    it "#GET scenario tags" do
      stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags")
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
    
    it "#POST scenario tag" do
      data = {
        data: {
          attributes: {
            key: "Priority",
            value: "low"
          }
        }
      }
    
      stub = stub_request(:post, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags")
        .with(headers: auth_headers, body: data.to_json)
        .to_return(status: 200, body: {
          data: {
              type: "tags",
              id: "1",
              attributes: {
                key: "Priority",
                value: "low"
              }
            }
          }.to_json)
    
      scenario_data = api.create_scenario_tag(@project_id, @scenario_id, data)
      expect(stub).to have_been_requested
      expect(scenario_data.dig('data')).not_to be_empty
    end
    
    it "#PATCH scenario tag" do
      data = {
        data: {
          type: "tags",
          id: "1",
          attributes: {
            key: "Priority",
            value: "low"
          }
        }
      }
    
      stub = stub_request(:patch, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags/#{@tag_id}")
        .with(headers: auth_headers, body: data.to_json)
        .to_return(status: 200, body: data.to_json)
    
      scenario_data = api.update_scenario_tag(@project_id, @scenario_id, @tag_id, data)
      expect(stub).to have_been_requested
      expect(scenario_data.dig('data')).not_to be_empty
    end
    
    it "#DELETE scenario tag" do
      stub = stub_request(:delete, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/tags/#{@tag_id}")
        .with(headers: auth_headers)
        .to_return(status: 200)
    
      api.delete_scenario_tag(@project_id, @scenario_id, @tag_id)
      expect(stub).to have_been_requested
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
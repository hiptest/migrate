require './lib/api/api'
require 'webmock/rspec'

RSpec.describe API::Hiptest, 'API Parameters' do
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
    @scenario_id = 11
    @parameter_id = 21
  end
  
  it "#GET parameters" do
    stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/parameters")
      .with(headers: auth_headers)
      .to_return(status: 200, body: {
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
      }.to_json)
    
    scenarios_data = api.get_scenario_parameters(@project_id, @scenario_id)
    expect(stub).to have_been_requested
    expect(scenarios_data.dig('data').any?).to be_truthy
  end
  
  it "#GET parameter" do
    stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/parameters/#{@parameter_id}")
      .with(headers: auth_headers)
      .to_return(status: 200, body: {
        data: {
            type: "parameters",
            id: "1",
            attributes: {
                name: "Invisibility"
            }
          }
        }.to_json)
  
    scenarios_data = api.get_scenario_parameter(@project_id, @scenario_id, @parameter_id)
    expect(stub).to have_been_requested
    expect(scenarios_data).to eq({
      "data" => {
          "type" => "parameters",
          "id" => "1",
          "attributes" => {
              "name" => "Invisibility"
          }
        }
      })
  end
  
  it "#POST parameter" do
    data = {
      data: {
        attributes: {
          name: "Invisibility"
        }
      }
    }
  
    stub = stub_request(:post, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/parameters")
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: {
        data: {
            type: "parameters",
            id: "1",
            attributes: {
                name: "Invisibility"
            }
          }
        }.to_json)
  
    scenario_data = api.create_scenario_parameter(@project_id, @scenario_id, data)
    expect(stub).to have_been_requested
    expect(scenario_data.dig('data')).not_to be_empty
  end
  
  it "#PATCH parameter" do
    data = {
      data: {
        type: "parameters",
        id: "1",
        attributes: {
          name: "Invulnerability"
        }
      }
    }
  
    stub = stub_request(:patch, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/parameters/#{@parameter_id}")
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: data.to_json)
  
    scenario_data = api.update_scenario_parameter(@project_id, @scenario_id, @parameter_id, data)
    expect(stub).to have_been_requested
    expect(scenario_data.dig('data')).not_to be_empty
  end
  
  it "#DELETE parameter" do
    stub = stub_request(:delete, "https://hiptest.net/api/projects/#{@project_id}/scenarios/#{@scenario_id}/parameters/#{@parameter_id}")
      .with(headers: auth_headers)
      .to_return(status: 200)
  
    api.delete_scenario_parameter(@project_id, @scenario_id, @parameter_id)
    expect(stub).to have_been_requested
  end
end
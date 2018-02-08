require './lib/api/api'
require 'webmock/rspec'

RSpec.describe API::Hiptest, 'API Folders' do
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
    @folder_id = 1
  end
  
  it "#GET folders" do
    stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/folders")
      .with(headers: auth_headers)
      .to_return(status: 200, body: {
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
      }.to_json)
    
    folders_data = api.get_folders(@project_id)
    expect(stub).to have_been_requested
    expect(folders_data.dig('data').any?).to be_truthy
  end
  
  it "#GET folder" do
    stub = stub_request(:get, "https://hiptest.net/api/projects/#{@project_id}/folders/#{@folder_id}")
      .with(headers: auth_headers)
      .to_return(status: 200, body: {
        data: {
            type: "folders",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }
        }.to_json)
    
    folders_data = api.get_folder(@project_id, @folder_id)
    expect(stub).to have_been_requested
    expect(folders_data).to eq({
      "data" => {
          "type" => "folders",
          "id" => "1",
          "attributes" => {
              "name" => "I've got the power"
          }
        }
      })
  end
  
  it "#POST folder" do
    data = {
      data: {
        attributes: {
          name: "I've got the power"
        }
      }
    }
    
    stub = stub_request(:post, "https://hiptest.net/api/projects/#{@project_id}/folders")
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: {
        data: {
            type: "folders",
            id: "1",
            attributes: {
                name: "I've got the power"
            }
          }
        }.to_json)
      
    folder_data = api.create_folder(@project_id, data)
    
    expect(stub).to have_been_requested
    expect(folder_data.dig('data')).not_to be_empty
  end
  
  it "#PATCH folder" do
    data = {
      data: {
        type: "folders",
        id: "1",
        attributes: {
          name: "I've got the power"
        }
      }
    }
    
    stub = stub_request(:patch, "https://hiptest.net/api/projects/#{@project_id}/folders/#{@folder_id}")
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: data.to_json)
      
    folder_data = api.update_folder(@project_id, @folder_id, data)
    
    expect(stub).to have_been_requested
    expect(folder_data.dig('data')).not_to be_empty
  end
  
  it "#DELETE folder" do
    stub = stub_request(:delete, "https://hiptest.net/api/projects/#{@project_id}/folders/#{@folder_id}")
      .with(headers: auth_headers)
      .to_return(status: 200)
    
    api.delete_folder(@project_id, @folder_id)
    expect(stub).to have_been_requested
  end
end
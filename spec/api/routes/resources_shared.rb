require 'spec_helper'

shared_examples 'an api resource model' do
  let(:resource_nested_level) { resource_type.split('_').count }
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
  
  
  let(:resource_type) { raise NotImplementedError }
  
  let(:index_route){ raise NotImplementedError }
  let(:index_response_data){ raise NotImplementedError }
  
  let(:show_route){ raise NotImplementedError }
  let(:show_response_data){ raise NotImplementedError }
  
  let(:create_data){ raise NotImplementedError }
  let(:create_response_data){ raise NotImplementedError }
  
  let(:update_data){ raise NotImplementedError }
  let(:update_response_data){ update_data }
  
  
  it "#GET resources" do
    stub = stub_request(:get, index_route)
      .with(headers: auth_headers)
      .to_return(status: 200, body: index_response_data.to_json)
      
    unless resource_nested_level == 1
      resources_data = api.send("get_#{resource_type.pluralize}", 1, 1)
    else
      resources_data = api.send("get_#{resource_type.pluralize}", 1)
    end
    
    expect(stub).to have_been_requested
    expect(resources_data.dig('data').any?).to be_truthy
  end
  
  it "#GET resource" do
    stub = stub_request(:get, show_route)
      .with(headers: auth_headers)
      .to_return(status: 200, body: show_response_data.to_json)
    
    unless resource_nested_level == 1
      api.send("get_#{resource_type.singularize}", 1, 1, 1)
    else
      api.send("get_#{resource_type.singularize}", 1, 1)
    end
    expect(stub).to have_been_requested
  end
  
  it "#POST resource" do
    stub = stub_request(:post, index_route)
      .with(headers: auth_headers, body: create_data.to_json)
      .to_return(status: 200, body: create_response_data.to_json)
      
    unless resource_nested_level == 1
      resource_data = api.send("create_#{resource_type.singularize}", 1, 1, create_data)
    else
      resource_data = api.send("create_#{resource_type.singularize}", 1, create_data)
    end
    
    expect(stub).to have_been_requested
    expect(resource_data.dig('data')).not_to be_empty
  end
  
  it "#PATCH resource" do
    stub = stub_request(:patch, show_route)
      .with(headers: auth_headers, body: update_data.to_json)
      .to_return(status: 200, body: update_response_data.to_json)
      
    unless resource_nested_level == 1
      resource_data = api.send("update_#{resource_type.singularize}", 1, 1, 1, update_data)
    else
      resource_data = api.send("update_#{resource_type.singularize}", 1, 1, update_data)
    end
    
    expect(stub).to have_been_requested
    expect(resource_data.dig('data')).not_to be_empty
  end
  
  it "#DELETE resource" do
    stub = stub_request(:delete, show_route)
      .with(headers: auth_headers)
      .to_return(status: 200)
    
    unless resource_nested_level == 1 
      api.send("delete_#{resource_type.singularize}", 1, 1, 1)
    else
      api.send("delete_#{resource_type.singularize}", 1, 1)
    end
    
    expect(stub).to have_been_requested
  end
end
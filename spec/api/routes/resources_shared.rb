require 'spec_helper'

shared_examples 'an API CRUD resource' do
  let(:resource_type_main) { raise NotImplementedError }
  
  let(:index_route_main){ raise NotImplementedError }
  let(:index_response_data_main){ raise NotImplementedError }
  
  let(:show_route_main){ raise NotImplementedError }
  let(:show_response_data_main){ raise NotImplementedError }
  
  let(:create_data_main) { raise NotImplementedError }
  let(:create_response_data_main) { raise NotImplementedError }
  
  let(:update_data_main) { raise NotImplementedError }
  let(:update_response_data_main) { update_data_main }
  
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
  
  it_behaves_like 'an API updatable resource' do
    let(:resource_type) { resource_type_main }
    let(:route) { show_route_main }
    let(:data) { update_data_main }
    let(:response_data) { update_response_data_main }
  end
  
  it_behaves_like 'an API deletable resource' do
    let(:resource_type) { resource_type_main }
    let(:route) { show_route_main }
  end
end

shared_examples 'an API readable resource' do
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
  
  
  it "#GET resources" do
    stub = stub_request(:get, index_route)
      .with(headers: auth_headers)
      .to_return(status: 200, body: index_response_data.to_json)
    
    case resource_nested_level
    when 0
      resources_data = api.send("get_#{resource_type.pluralize}")
    when 1
      resources_data = api.send("get_#{resource_type.pluralize}", 1)
    when 2
      resources_data = api.send("get_#{resource_type.pluralize}", 1, 1)
    when 3
      resources_data = api.send("get_#{resource_type.pluralize}", 1, 1, 1)
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
    
    case resource_nested_level
    when 0
      api.send("get_#{resource_type.singularize}", 1)
    when 1
      api.send("get_#{resource_type.singularize}", 1, 1)
    when 2
      api.send("get_#{resource_type.singularize}", 1, 1, 1)
    when 3
      api.send("get_#{resource_type.singularize}", 1, 1, 1, 1)
    else
      api.send("get_#{resource_type.singularize}", 1, 1)
    end
    
    expect(stub).to have_been_requested
  end
end

shared_examples 'an API creatable resource' do
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
  
  let(:route){ raise NotImplementedError }
  let(:data){ raise NotImplementedError }
  let(:response_data){ raise NotImplementedError }
  
  it "#POST resource" do
    stub = stub_request(:post, route)
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: response_data.to_json)
      
    
    case resource_nested_level
    when 1
      resource_data = api.send("create_#{resource_type.singularize}", 1, data)
    when 2
      resource_data = api.send("create_#{resource_type.singularize}", 1, 1, data)
    when 3
      resource_data = api.send("create_#{resource_type.singularize}", 1, 1, 1, data)
    end
    
    expect(stub).to have_been_requested
    expect(resource_data.dig('data')).not_to be_empty
  end
end

shared_examples 'an API updatable resource' do
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
  
  let(:route){ raise NotImplementedError }
  let(:data){ raise NotImplementedError }
  let(:response_data){ data }
  
  it "#PATCH resource" do
    stub = stub_request(:patch, route)
      .with(headers: auth_headers, body: data.to_json)
      .to_return(status: 200, body: response_data.to_json)
      
      case resource_nested_level
      when 1
        resource_data = api.send("update_#{resource_type.singularize}", 1, 1, data)
      when 2
        resource_data = api.send("update_#{resource_type.singularize}", 1, 1, 1, data)
      when 3
        resource_data = api.send("update_#{resource_type.singularize}", 1, 1, 1, 1, data)
      end
    
    expect(stub).to have_been_requested
    expect(resource_data.dig('data')).not_to be_empty
  end
end

shared_examples 'an API deletable resource' do
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
  let(:route){ raise NotImplementedError }
  
  it "#DELETE resource" do
    stub = stub_request(:delete, route)
      .with(headers: auth_headers)
      .to_return(status: 200)
    
      case resource_nested_level
      when 1
        api.send("delete_#{resource_type.singularize}", 1, 1)
      when 2
        api.send("delete_#{resource_type.singularize}", 1, 1, 1)
      when 3
        api.send("delete_#{resource_type.singularize}", 1, 1, 1, 1)
      else
        api.send("delete_#{resource_type.singularize}", 1, 1)
      end
    
    expect(stub).to have_been_requested
  end
end
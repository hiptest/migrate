require './lib/api/hiptest'
require 'webmock/rspec'

RSpec.describe API::Hiptest, 'API Scenarios' do
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

  context "routing system" do

    it "raises an error when resource is not defined in routes" do
      expect {
        api.get_bidibou(@project_id, @bidibou_id)
      }.to raise_error(ArgumentError, "Route 'bidibou' is not found (looked up name = get_bidibou)")
    end

    it "raises an error when action resource is not defined in routes" do
      expect {
        api.create_folderTag(@project_id, @folder_id, {})
      }.to raise_error(ArgumentError, "Action 'create' not found for route projects/folders/tags")
    end

    it "raises an error when the method has no sense" do
      expect {
        api.culture(@project_id, @folder_id, {})
      }.to raise_error(ArgumentError, "The method 'culture' doesn't exist or isn't implemented yet")
    end

  end
end

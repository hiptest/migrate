require 'spec_helper'

require './lib/models/project'
require './lib/models/scenario'
require './lib/models/test-run'

describe Models::TestRun do
  let(:api) { double(API::Hiptest) }
  let(:project) {
    project = Models::Project.instance
    project.name = "Game of thrones"
    
    7.times do |i|
      f = project.folders << Models::Folder.new("Season #{i+1}")
      10.times do |j|
        f.scenarios << Models::Scenario.new("Ep. #{j+1}")
      end
    end
  }
  
  let(:tr) { Models::TestRun.new('GOT run') }
  let(:tr_index_response) {
    {
      "data" => [
        {
          "type" => "test-runs",
          "id" => "1",
          "attributes" => {
            "name" => "Daredevil run",
            "description" => "",
            "statuses" => {
              "passed" => 3,
              "failed" => 1,
              "retest" => 4,
              "undefined" => 1,
              "blocked" => 5,
              "skipped" => 9,
              "wip" => 0
            }
          }
        }, {
          "type" => "test-runs",
          "id" => "2",
          "attributes" => {
            "name" => "GOT run",
            "description" => "",
            "statuses" => {
              "passed" => 3,
              "failed" => 1,
              "retest" => 4,
              "undefined" => 1,
              "blocked" => 5,
              "skipped" => 9,
              "wip" => 0
            }
          }
        }
      ]
    }
  }
  
  let(:tr_create_data) {
    {
      data: {
        attributes: {
          name: tr.name,
          description: ""
        }
      }
    }
  }
  
  let(:tr_create_response) {
    {
      "data" => {
        "id" => "1664",
        "type" => "",
        "attributes" => {
          "name" => tr.name,
          "description" => ""
        }
      }
    }
  }
  
  before do
    tr.class.api = api
  end
  
  context "when saving" do
    it "create a new test run" do
      allow(api).to receive(:get).with(URI("https://hiptest.net/api/projects/1/test_runs")).and_return({ "data" => [] })
      allow(api).to receive(:post).with(URI("https://hiptest.net/api/projects/1/test_runs"), tr_create_data).and_return(tr_create_response)
      
      expect(tr.api_exists?).not_to be_truthy
      
      tr.save
      
      expect(api).to have_received(:post)
      expect(tr.id).to eq "1664"
    end
    
    it "do nothing if test run doesn't already exist" do
      allow(api).to receive(:get).with(URI("https://hiptest.net/api/projects/1/test_runs")).and_return(tr_index_response)
      allow(api).to receive(:post)
      
      tr.save
      
      expect(api).not_to have_received(:post)
    end
  end
  
  context "after saving" do
    it "fetch tests" do
      allow(api).to receive(:get).with(URI("https://hiptest.net/api/projects/1/test_runs")).and_return(tr_index_response)
      allow(tr).to receive(:fetch_tests)
      
      tr.save
      
      expect(tr).to have_received(:fetch_tests)
    end
    
    it "push results" do
      allow(api).to receive(:get).with(URI("https://hiptest.net/api/projects/1/test_runs")).and_return(tr_index_response)
      allow(tr).to receive(:push_results)
      
      tr.save
      
      expect(tr).to have_received(:push_results)
    end
  end
end
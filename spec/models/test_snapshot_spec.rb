require 'spec_helper'

require './lib/models/project'
require './lib/models/scenario'
require './lib/models/test_run'
require './lib/models/test_snapshot'

describe Models::TestSnapshot do
  let(:api) { double(API::Hiptest) }
  
  let(:scenario) { 
    sc = Models::Scenario.new('Tintin et Milou')
    sc.jira_id = 'Plic-12'
    sc
  }
  let(:test_snapshot) { Models::TestSnapshot.new(id: 1, name: 'Tintin et Milou', status: "UNEXECUTED", test_run_id: 1) }
  
  let!(:test_run) {
    tr = Models::TestRun.new('Hergé')
    tr.test_snapshots << test_snapshot
    tr.add_status_to_cache(scenario: scenario, status: "FAILED", author: "Migration script")
    tr
  }
  
  let(:related_scenario_response) {
    {
      "data" =>  {
        "type" =>  "test-snapshots",
        "id" =>  "1",
        "attributes" =>  {
          "name" =>  "Tintin et Milou",
          "status" =>  "passed"
        }
      },
      "included" =>  [
        {
          "type" =>  "scenarios",
          "id" =>  "10",
          "attributes" =>  {
            "name" =>  "Tintin et Milou",
            "description" =>  "Il a mal au rein Tintin"
          }
        }
      ]
    }
  }
  
  let(:related_scenario_tags_response) {
    {
      "data" =>  [
        {
          "type" =>  "tags",
          "id" =>  "1",
          "attributes" =>  {
            "key" =>  "Status",
            "value" =>  "InProgress"
          }
        },
        {
          "type" =>  "tags",
          "id" =>  "2",
          "attributes" =>  {
            "key" =>  "JIRA",
            "value" =>  "Plic-12"
          }
        }
      ]
    }
  }
  
  let(:create_result_data) {
    {
      data: {
        type: "test-results", 
        attributes: {
          status: "passed", 
          'status-author': "Tintin", 
          description: "Roux"
        }
      }
    }
  }
  
  before do
    ENV['HT_PROJECT'] = "1"
    Models::TestSnapshot.api = api
  end
  
  context "when pushes results" do
    it 'finds related scenario' do
      allow(api).to receive(:get).with(URI("https://hiptest.net/api/projects/1/test_runs/1/test_snapshots/1?include=scenario")).and_return(related_scenario_response)
      allow(api).to receive(:get_scenario_tags).with("1", "10").and_return(related_scenario_tags_response)
      
      sc = test_snapshot.related_scenario
      expect(sc).not_to be_nil
    end
    
    it 'sends the test result to hiptest' do
      allow(api).to receive(:post).with(URI("https://hiptest.net/api/projects/1/test_runs/1/test_snapshots/1/test_results"), create_result_data)
      
      test_snapshot.push_results("passed", "Tintin", "Roux")
      
      expect(api).to have_received(:post).with(URI("https://hiptest.net/api/projects/1/test_runs/1/test_snapshots/1/test_results"), create_result_data)
    end
  end
end
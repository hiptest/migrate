require 'spec_helper'

require './lib/models/project'
require './lib/models/scenario'
require './lib/models/test_run'
require './lib/models/folder'

describe Models::TestRun do
  let(:api) { double(API::Hiptest) }
  let(:project) {
    project = Models::Project.instance
    project.name = "Game of thrones"
    project
  }

  let(:scenario) {
    sc = Models::Scenario.new('Introduction')
    sc.jira_id = 'INTRO-1'
    project.scenarios << sc
    sc
  }

  let(:tr) {
    tr = Models::TestRun.new('GOT run')
    allow(tr).to receive(:wait_for_test_run) ## Important
    tr
  }

  let(:tr_index_response) {
    {
      "data" => [
        {
          "type" => "test-runs",
          "id" => "1",
          "attributes" => {
            "name" => "Peaky Blinders",
            "description" => "",
            "statuses" => {
              "passed" => 3,
              "failed" => 1,
              "retest" => 4,
              "undefined" => 1,
              "blocked" => 5,
              "skipped" => 9,
              "wip" => 0,
            },
          },
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
              "wip" => 0,
            },
          },
        },
      ],
    }
  }

  let(:tr_create_data) {
    {
      data: {
        attributes: {
          name: tr.name,
          description: "",
        },
      },
    }
  }

  let(:tr_create_response) {
    {
      "data" => {
        "id" => "1664",
        "type" => "",
        "attributes" => {
          "name" => tr.name,
          "description" => "",
        },
      },
    }
  }

  let(:ts_response) {
    {
      "data" => [
        {
          "type" => "test-snapshots",
          "id" => "1",
          "attributes" => {
            "name" => "Oberyn became blind",
            "definition-json" => {
              "scenario_name" => "Oberyn became blind",
              "folder_snapshot_id" => 1,
              "steps" => [
                {
                  "action" => "The mountain cruches Oberyn eyes",
                },
                {
                  "result" => "Then Oberyn doesn't see anymore",
                },
              ],
              "index" => 0,
            },
            "status" => "failed",
            "folder-snapshot-id" => 2,
          },
        },
        {
          "type" => "test-snapshots",
          "id" => "2",
          "attributes" => {
            "name" => "Thomas Shelby is badass",
            "definition-json" => {
              "scenario_name" => "Thomas Shelby is badass",
              "folder_snapshot_id" => 2,
              "steps" => [
                {
                  "action" => "Thomas killed the ritals",
                },
                {
                  "result" => "Then Thomas won",
                },
              ],
              "index" => 0,
            },
            "status" => "success",
            "folder-snapshot-id" => 5,
          },
        },
      ],
    }
  }

  before do
    ENV['HT_PROJECT'] = "1"
    tr.class.api = api
  end

  context "when saving" do
    before do
      allow(api).to receive(:get_testRun_testSnapshots).and_return(ts_response)
      allow(tr).to receive(:after_save)
    end

    it "creates a new test run" do
      allow(api).to receive(:get_testRuns).and_return({"data" => []})
      allow(api).to receive(:create_testRun).and_return(tr_create_response)

      expect(tr.api_exists?).not_to be_truthy

      tr.save


      expect(api).to have_received(:create_testRun)
      expect(tr.id).to eq "1664"
    end

    it "does nothing if test run doesn't already exist" do
      allow(api).to receive(:get_testRuns).and_return(tr_index_response)
      allow(api).to receive(:create_testRun)

      tr.save

      expect(api).not_to have_received(:create_testRun)
    end
  end

  context "after saving" do
    it "fetches tests" do
      allow(api).to receive(:get_testRuns).and_return(tr_index_response)
      allow(api).to receive(:get_testRun_testSnapshots).and_return(ts_response)
      allow(tr).to receive(:push_results)

      tr.save

      expect(api).to have_received(:get_testRun_testSnapshots).at_least(:once)
      expect(tr.test_snapshots.count).to eq 2
    end

    it "assigns correct status to test snapshots" do
      ts = Models::TestSnapshot.new(
        id: 1,
        name: scenario.name,
        status: "UNEXECUTED",
        test_run_id: tr.id,
        folder_snapshot_id: nil,
      )
      tr.id = 2
      tr.add_status_to_cache(scenario: scenario, status: "passed", author: "Austin Power", description: "Yeah baby yeah!")
      tr.test_snapshots << ts

      allow(ts).to receive(:related_scenario).and_return(scenario)
      allow(Models::TestSnapshot).to receive(:process_results)
      allow(ts).to receive(:push_results)

      tr.push_results

      expect(ts.status).to eq "passed"
    end

    it "pushes results" do
      allow(api).to receive(:get_testRuns).and_return(tr_index_response)
      allow(api).to receive(:get_testRun_testSnapshots).and_return(ts_response)
      allow(tr).to receive(:push_results)

      tr.save

      expect(tr).to have_received(:push_results)
    end

    it "does not call #push_results on test snapshots that are not in cache" do
      ts = Models::TestSnapshot.new(
        id: 1,
        name: scenario.name,
        status: "UNEXECUTED",
        test_run_id: tr.id,
        folder_snapshot_id: nil,
      )
      tr.id = 2
      tr.test_snapshots << ts

      allow(ts).to receive(:related_scenario).and_return(scenario)
      allow(Models::TestSnapshot).to receive(:process_results)
      allow(ts).to receive(:push_results)

      tr.push_results

      expect(ts).not_to have_received(:push_results)
    end
  end
end

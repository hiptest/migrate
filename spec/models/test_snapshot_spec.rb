require 'colorize'

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
    Models::TestSnapshot.class_variable_set(:@@results_path, './spec/test_snapshots_results.txt')
    Models::TestSnapshot.class_variable_set(:@@pushed_results, [])
    Models::TestSnapshot.api = api
  end

  after do
    if File.exists?('./spec/test_snapshots_results.txt')
      File.delete('./spec/test_snapshots_results.txt')
    end
  end

  context "#is_already_pushed?" do
    it 'returns true if test_snapshot id is in the result file' do
      Models::TestSnapshot.class_variable_set(:@@pushed_results, [test_snapshot.id])
      expect(test_snapshot.is_already_pushed?).to be_truthy
    end
  end

  context "TestSnapshot#process_results" do
    it "fills pushed_results with test_snapshot ids that are already pushed" do
      File.open(Models::TestSnapshot.class_variable_get(:@@results_path), "w") do |f|
        f.puts(test_snapshot.id)
      end

      expect{
        Models::TestSnapshot.process_results
      }.to change{
        Models::TestSnapshot.class_variable_get(:@@pushed_results).count
      }.by 1

      expect(Models::TestSnapshot.class_variable_get(:@@pushed_results)).to eq ["#{test_snapshot.id}"]
    end
  end

  context "when pushes results" do
    it 'finds related scenario' do
      allow(api).to receive(:get_testSnapshot_including_scenario).and_return(related_scenario_response)
      allow(api).to receive(:get_scenarioTags).and_return(related_scenario_tags_response)

      sc = test_snapshot.related_scenario
      expect(sc).not_to be_nil
    end

    it 'sends the test result to hiptest' do
      allow(api).to receive(:create_testResult)

      test_snapshot.push_results("passed", "Tintin", "Roux")

      expect(api).to have_received(:create_testResult)
    end

    it "transform zephyr status into hiptest status equivalent" do
      expect(Models::TestSnapshot.status_map("pass")).to eq "passed".green
      expect(Models::TestSnapshot.status_map("fail")).to eq "failed".red
      expect(Models::TestSnapshot.status_map("wip")).to eq "wip".yellow
      expect(Models::TestSnapshot.status_map("blocked")).to eq "blocked".magenta
      expect(Models::TestSnapshot.status_map("unexecuted")).to eq "undefined"
      expect(Models::TestSnapshot.status_map("deferred")).to eq "skipped".blue
    end
  end
end

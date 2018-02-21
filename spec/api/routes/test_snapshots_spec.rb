require 'spec_helper'
require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API TestSnapshots' do
  let(:resource_type_main) { "testRun_testSnapshot" }
  let(:index_route_main) { "https://hiptest.net/api/projects/1/test_runs/1/test_snapshots" }
  let(:show_route_main) { "https://hiptest.net/api/projects/1/test_runs/1/test_snapshots/1" }
  
  it_behaves_like 'an API readable resource' do
    let(:resource_type) { resource_type_main }
    let(:index_route){ index_route_main }
    let(:index_response_data){
      {
        data: [
          {
            type: "test-snapshots",
            id: "1",
            attributes: {
              name: "",
              'definition-json': {
                scenario_name: "Find horcruxes",
                folder_snapshot_id: 1,
                steps: [
                  {
                    action: "Given Harry has one horcrux"
                  },
                  {
                    result: "Then he should destroy it"
                  },
                ],
                index: 0
              },
              status: "failed",
              'folder-snapshot-id': 1
            }
          },
          {
            type: "test-snapshots",
            id: "2",
            attributes: {
              name: "Defeat Voldemort",
              'definition-json': {
                scenario_name: "Defeat Voldemort",
                folder_snapshot_id: 2,
                steps: [
                  {
                    action: "Given Harry cast the Expelliarmus spell"
                  },
                  {
                    result: "Then Voldemort should be defeated"
                  }
                ],
                index: 0
              },
              status: "success",
              'folder-snapshot-id': 1
            }
          }
        ]
      }
    }
    
    let(:show_route){ show_route_main }
    let(:show_response_data){
      {
        type: "test-snapshots",
        id: "1",
        attributes: {
          name: "",
          'definition-json': {
            scenario_name: "Find horcruxes",
            folder_snapshot_id: 1,
            steps: [
              {
                action: "Given Harry has one horcrux"
              },
              {
                result: "Then he should destroy it"
              },
            ],
            index: 0
          },
          status: "failed",
          'folder-snapshot-id': 1
        }
      }
    }
  end
end
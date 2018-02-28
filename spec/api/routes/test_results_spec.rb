require './spec/api/routes/resources_shared'

RSpec.describe API::Hiptest, 'API TestResult' do
  let(:resource_type_main) { "testResult" }
  let(:create_route_main) { "https://hiptest.net/api/projects/1/test_runs/1/test_snapshots/1/test_results" }

  it_behaves_like 'an API creatable resource' do
    let(:resource_type) { resource_type_main }
    let(:route){ create_route_main }
    let(:data) {
      {
        data: {
          type: "test-results",
          attributes: {
            status: "passed",
            'status-author': "Harry",
            description: "All was well"
          }
        }
      }
    }

    let(:response_data){
      {
        data: {
          type: "test-results",
          id: "1",
          attributes: {
            status: "passed",
            description: "",
            'status-author': "Harry"
          }
        }
      }
    }
  end
end

require './lib/models/scenario'

require './spec/models/models_shared'

describe Models::Scenario do
  it_behaves_like 'a model' do
    let(:an_existing_object ) { Models::Scenario.new('My first scenario') }
    let(:an_unknown_object ) { Models::Scenario.new('My second scenario') }

    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios'}
    let(:create_url) {'https://hiptest.net/api/projects/1/scenarios'}
    let(:update_url) {'https://hiptest.net/api/projects/1/scenarios/1664'}

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My first scenario'
          }
        }
      }
    }
    let(:update_data) { create_data }

    let(:find_results) {
      {
        data: [
          {type: 'object', id: '1664', attributes: {name: 'My first scenario'}}
        ]
      }.to_json
    }
  end
end

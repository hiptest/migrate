require './lib/models/dataset'
require './lib/models/scenario'

require './spec/models/models_shared'

describe Models::Dataset do
  it_behaves_like 'a model' do
    let(:an_existing_object ) {
      scenario = Models::Scenario.new('My related scenario')
      scenario.id = 1
      scenario.jira_id = 'JIRA-1'
      dataset = Models::Dataset.new('JIRA-1')
      dataset.name = 'My dataset'
      dataset.data = {
        'parameter 1' => 'value 1'
      }
      dataset
    }
    let(:an_unknown_object ) {
      scenario = Models::Scenario.new('My related scenario')
      scenario.id = 1
      scenario.jira_id = 'JIRA-2'
      Models::Dataset.new('JIRA-2')
    }

    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios/1/datasets'}
    let(:create_url) {'https://hiptest.net/api/projects/1/scenarios/1/datasets'}
    let(:update_url) {'https://hiptest.net/api/projects/1/scenarios/1/datasets/1664'}

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My dataset'
          }
        }
      }
    }
    let(:update_data) { create_data }

    let(:created_data) {
      {
        type: 'datasets',
        id: '1664',
        attributes: {
          name: 'My dataset'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'datasets',
          'id' => '1664',
          'attributes' => {
            'name' => 'My dataset',
            'data' => {
              'parameter 1' => 'value 1'
            }
          }
        }
      ]
    }

  end
end
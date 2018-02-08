require './lib/models/scenario'

require './spec/models/models_shared'

describe Models::Scenario do
  it_behaves_like 'a model' do
    let(:an_existing_object ) {
      sc = Models::Scenario.new('My first scenario')
      sc.jira_id='PLOP-1'
      sc
    }
    let(:an_unknown_object ) {
      sc = Models::Scenario.new('My second scenario')
      sc.jira_id='PLOP-2'
      sc
    }

    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios/find_by_tags'}
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

    let(:created_data) {
      {
        type: 'scenarios',
        id: '1664',
        attributes: {
          name: 'My first scenario'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'object',
          'id' => '1664',
          'attributes' => {
            'name' => 'My first scenario'
          }
        }
      ]
    }
  end

  context 'api_exists?' do
    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios/find_by_tags'}
    let(:find_results) {
      {
        'data' => find_data
      }.to_json
    }
    let(:scenario ) {
      sc = Models::Scenario.new('My first scenario')
      sc.jira_id='PLOP-1'
      sc
    }

    context 'when only one result is returned' do
      let(:find_data) {
        [
          {
            'type' => 'object',
            'id' => '1664',
            'attributes' => {
              'name' => 'My first scenario (2)'
            }
          }
        ]
      }

      it 'checks that the scenario name is the beginning of the returned result' do
        with_stubbed_request(find_url, find_results) do
          expect(scenario.api_exists?).to be true
          expect(scenario.id).to eq(find_data.first['id'])
        end
      end
    end

    context 'when multiple results are returned' do
      let(:find_data) {
        [
          {
            'type' => 'object',
            'id' => '1664',
            'attributes' => {
              'name' => 'Whatever the name is'
            }
          },
          {
            'type' => 'object',
            'id' => '1665',
            'attributes' => {
              'name' => 'My first scenario (1)'
            }
          },
          {
            'type' => 'object',
            'id' => '1666',
            'attributes' => {
              'name' => 'My first scenario'
            }
          }
        ]
      }

      it 'uses the first result which name starts with the scenario name' do
        with_stubbed_request(find_url, find_results) do
          expect(scenario.api_exists?).to be true
          expect(scenario.id).to eq(find_data[1]['id'])
        end
      end
    end
  end
end

require './lib/models/scenario'

require './spec/models/models_shared'

describe Models::Scenario do
  it_behaves_like 'a model' do
    let(:api){ double("API::Hiptest") }
    
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

    let(:resource_id) { 1664 }

    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios/find_by_tags'}
    
    let(:query_that_found) { '?key=JIRA&value=PLOP-1' }
    let(:query_that_not_found) { '?key=JIRA&value=PLOP-2' }
    
    let(:create_url) {'https://hiptest.net/api/projects/1/scenarios'}
    let(:update_url) { "https://hiptest.net/api/projects/1/scenarios/#{resource_id}" }

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My first scenario',
            description: "",
            "folder-id": nil
          }
        }
      }
    }
    
    let(:update_data) { 
      {
        data: {
          id: '1664',
          type: 'scenarios',
          attributes: {
            description: "",
            'folder-id': nil,
            definition: "scenario '#{an_existing_object.name}' do\n\nend"
          }
        }
      }
    }

    let(:created_data) {
      {
        'type' => 'scenarios',
        'id' => '1664',
        'attributes' => {
          'name' => 'My first scenario'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'scenarios',
          'id' => '1664',
          'attributes' => {
            'name' => 'My first scenario'
          }
        }
      ]
    }
  end

  context 'api_exists?' do
    let(:api){ double("API::Hiptest") }
    let(:find_url) {'https://hiptest.net/api/projects/1/scenarios/find_by_tags?key=JIRA&value=PLOP-1'}
    let(:find_results) {
      {
        'data' => find_data
      }
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
            'type' => 'scenarios',
            'id' => '1664',
            'attributes' => {
              'name' => 'My first scenario (2)'
            }
          }
        ]
      }

      it 'checks that the scenario name is the beginning of the returned result' do
        allow(api).to receive(:get).with(URI(find_url)).and_return(find_results)
        scenario.class.api = api
        
        expect(scenario.api_exists?).to be true
        expect(scenario.id).to eq(find_data.first['id'])
      end
    end

    context 'when multiple results are returned' do
      let(:find_data) {
        [
          {
            'type' => 'scenarios',
            'id' => '1664',
            'attributes' => {
              'name' => 'Whatever the name is'
            }
          },
          {
            'type' => 'scenarios',
            'id' => '1665',
            'attributes' => {
              'name' => 'My first scenario (1)'
            }
          },
          {
            'type' => 'scenarios',
            'id' => '1666',
            'attributes' => {
              'name' => 'My first scenario'
            }
          }
        ]
      }

      it 'uses the first result which name starts with the scenario name' do
        allow(api).to receive(:get).with(URI(find_url)).and_return(find_results)
        scenario.class.api = api
        
        expect(scenario.api_exists?).to be true
        expect(scenario.id).to eq(find_data[1]['id'])
      end
    end
  end
end

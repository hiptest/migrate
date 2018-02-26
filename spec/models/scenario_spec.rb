require 'spec_helper'

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
            definition: "scenario '#{an_existing_object.name}' do\nend"
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
  
  before do
    api = double(API::Hiptest)
    Models::Scenario.class_variable_set(:@@api, api)
  end
  
  context 'api_identical?' do
    let(:scenario){ Models::Scenario.new("Tim's first scenario".double_quotes_replaced.single_quotes_escaped) }
    let(:find_data) {
      {
        'type' => 'scenarios',
        'id' => '1664',
        'attributes' => {
          'name' => "Tim's first scenario"
        }
      }
    }
    
    it "compare name with single_quotes equivalency" do
      expect(scenario.api_identical?(find_data)).to be_truthy
    end
  end

  context 'api_exists?' do
    let(:api){ Models::Scenario.class_variable_get(:@@api) }
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
        allow(api).to receive("find_scenario_by_jira_id").and_return(find_results)
        scenario.class.api = api

        expect(scenario.api_exists?).to be true
        expect(scenario.id).to eq(find_data.first['id'])
      end
    end

    context 'when multiple results are returned' do
      let(:api){ Models::Scenario.class_variable_get(:@@api) }
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
        allow(api).to receive("find_scenario_by_jira_id").and_return(find_results)
        scenario.class.api = api
        
        expect(scenario.api_exists?).to be true
        expect(scenario.id).to eq(find_data[1]['id'])
      end
    end
  end

  context "when saving the first time" do
    let(:api){ Models::Scenario.class_variable_get(:@@api) }

    let(:scenario ) {
      sc = Models::Scenario.new('My first scenario')
      sc.jira_id='PLOP-1'
      sc
    }

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

    let(:created_data){
      {
        'type' => 'scenarios',
        'id' => '1664',
        'attributes' => {
          'name' => 'My first scenario'
        }
      }
    }

    it "creates the scenario then updates it with its definition" do
      allow(api).to receive(:find_scenario_by_jira_id).and_return({ 'data' => []})
      allow(api).to receive(:get_scenarios).and_return({ 'data' => []})
      allow(api).to receive(:create_scenario).and_return(created_data)
      scenario.class.api = api

      allow(scenario).to receive(:update)
      expect(scenario.api_exists?).to be false

      scenario.save
      expect(scenario).to have_received(:update)
    end
  end

  context "scenarios are renamed before saving" do
    let(:api){ Models::Scenario.class_variable_get(:@@api) }

    let(:scenario ) {
      sc = Models::Scenario.new('My scenario')
      sc.jira_id='PLOP-1'
      sc
    }

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My scenario (4)',
            description: "",
            "folder-id": nil
          }
        }
      }
    }

    let(:created_data){
      {
        'type' => 'scenarios',
        'id' => '1664',
        'attributes' => {
          'name' => 'My scenario (4)'
        }
      }
    }

    it "a unique name is found based on the existing ones (case insensitive)" do
      scenario.name = 'My Scenario'
      
      allow(api).to receive(:get_scenarios).and_return({ 'data' => [
        {'type' => 'scenarios', 'attributes' => {'name' => 'My scenario'}},
        {'type' => 'scenarios', 'attributes' => {'name' => 'My scenario (1)'}},
        {'type' => 'scenarios', 'attributes' => {'name' => 'My scenario (2)'}},
        {'type' => 'scenarios', 'attributes' => {'name' => 'My scenario (3)'}},
        {'type' => 'scenarios', 'attributes' => {'name' => 'My scenario (5)'}},
      ]})
      
      create_data[:data][:attributes][:name] = 'My Scenario (4)'
      created_data['attributes']['name'] = 'My Scenario (4)'
      
      allow(api).to receive(:find_scenario_by_jira_id).and_return({ 'data' => []})
      allow(api).to receive(:create_scenario).and_return(create_data)
      
      allow(scenario).to receive(:update)
      
      scenario.class.api = api

      scenario.save
      expect(scenario.name).to eq('My Scenario (4)')
    end
  end
  
  context "when multiple scenarios have the same name" do
    let(:api){ double(API::Hiptest) }

    let(:scenario) {
      sc = Models::Scenario.new('My scenario')
      sc.id = "1664"
      sc.jira_id='PLOP-1'
      sc
    }
    
    before do
      allow(scenario).to receive(:api_exists?).and_return(true)
      allow(api).to receive(:update_scenario)
      allow(api).to receive(:get_scenario).with("1", "#{scenario.id}").and_return(
        {
          'data' => {
            'attributes' => {
              'name' => 'My scenario (1)'
            }
          }
        }
      )
      scenario.class.api = api
    end
    
    
    
    it 'retrieve the name from server before updating' do
      expect(scenario.name).to eq 'My scenario'
      scenario.update
      expect(scenario.name).to eq 'My scenario (1)'
    end
  end
end

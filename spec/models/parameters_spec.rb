require './lib/models/parameter'
require './lib/models/scenario'

require './spec/models/models_shared'

describe Models::Parameter do
  it_behaves_like 'a model' do
    let(:api){ double("API::Hiptest") }
    
    let(:an_existing_object ) {
      scenario = Models::Scenario.new('My related scenario')
      scenario.id = 1
      scenario.jira_id = 'JIRA-1'
      parameter = Models::Parameter.new('JIRA-1', "Yablibli")
      parameter
    }
    let(:an_unknown_object ) {
      scenario = Models::Scenario.new('My related scenario')
      scenario.id = 1
      scenario.jira_id = 'JIRA-2'
      Models::Parameter.new('JIRA-2', "Bidibop")
    }
    
    let(:resource_id) { 1664 }

    let(:find_url) {"#{ENV['HT_URI']}/projects/1/scenarios/1/parameters"}
    let(:create_url) {"#{ENV['HT_URI']}/projects/1/scenarios/1/parameters"}
    let(:update_url) {"#{ENV['HT_URI']}/projects/1/scenarios/1/parameters/1664"}

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'p0'
          }
        }
      }
    }
    
    let(:update_data) { 
      {
        :data=> {
          :attributes=> {
            :name=>"p0"
          }, 
          :id=>"1664", 
          :type=>"parameters"
        }
      }
    }

    let(:created_data) {
      {
        type: 'parameters',
        id: '1664',
        attributes: {
          name: 'p0'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'parameters',
          'id' => '1664',
          'attributes' => {
            'name' => 'p0'
          }
        }
      ]
    }

  end
end

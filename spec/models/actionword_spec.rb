require 'spec_helper'

require './lib/models/actionword'
require './spec/models/models_shared'

describe Models::Actionword do
  it_behaves_like 'a model' do
    let(:api){ double("API::Hiptest") }

    let(:an_existing_object ) {
      Models::Actionword.new('My first actionword')
    }
    let(:an_unknown_object ) {
      Models::Actionword.new('My second actionword')
    }

    let(:resource_id) { 1664 }

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My first actionword',
            description: ""
          }
        }
      }
    }

    let(:update_data) {
      {
        data: {
          id: '1664',
          type: 'actionwords',
          attributes: {
            description: "",
            definition: "actionword '#{an_existing_object.name}' (__free_text = \"\") do\nend"
          }
        }
      }
    }

    let(:created_data) {
      {
        'type' => 'actionwords',
        'id' => '1664',
        'attributes' => {
          'name' => 'My first actionword'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'actionwords',
          'id' => '1664',
          'attributes' => {
            'name' => 'My first actionword'
          }
        }
      ]
    }
  end
  
  context "when create new actionword" do
    it "single quotes are escaped from actionword name" do
      aw = Models::Actionword.find_or_create_by_name("Great actionword with 'single quotes'")
      expect(aw.name).to eq("Great actionword with \\'single quotes\\'")
    end
  end
  
  context "api_identical?" do
    let(:find_data) {
      {
        'type' => 'actionwords',
        'id' => '1664',
        'attributes' => {
          'name' => "Great actionword with 'single quotes'"
        }
      }
    }
    
    
    it "compare names with single quotes equivalency" do
      aw = Models::Actionword.find_or_create_by_name("Great actionword with 'single quotes'")
      expect(aw.api_identical?(find_data)).to be_truthy
    end
  end

  context 'api_exists?' do
    let(:api){ double("API::Hiptest") }
    let(:find_results) {
      {
        'data' => find_data
      }
    }
    let(:actionword ) {
      Models::Actionword.new('My first actionword')
    }

    context 'when multiple results are returned' do
      let(:find_data) {
        [
          {
            'type' => 'actionwords',
            'id' => '1664',
            'attributes' => {
              'name' => 'Whatever the name is'
            }
          },
          {
            'type' => 'actionwords',
            'id' => '1665',
            'attributes' => {
              'name' => 'My first actionword (1)'
            }
          },
          {
            'type' => 'actionwords',
            'id' => '1666',
            'attributes' => {
              'name' => 'My first actionword'
            }
          }
        ]
      }

      it 'uses the result that exaclty match the actionword name' do
        allow(api).to receive(:get_actionwords).and_return(find_results)
        actionword.class.api = api

        expect(actionword.api_exists?).to be true
        expect(actionword.id).to eq(find_data[2]['id'])
      end
    end
  end

  context "when saving" do
    let(:api){ double("API::Hiptest") }

    let(:actionword ) {
      Models::Actionword.new('My first actionword')
    }

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My first actionword',
            description: ""
          }
        }
      }
    }

    let(:created_data){
      {
        'type' => 'actionwords',
        'id' => '1664',
        'attributes' => {
          'name' => 'My first actionword'
        }
      }
    }

    it "creates the actionword then updates it with its definition" do
      allow(api).to receive(:get_actionwords).and_return('data' => [])
      allow(api).to receive(:create_actionword)
      actionword.class.api = api

      allow(actionword).to receive(:update)
      expect(actionword.api_exists?).to be false

      actionword.save
      expect(actionword).to have_received(:update)
    end
  end
end

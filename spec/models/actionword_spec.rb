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

    let(:find_url) {'https://hiptest.net/api/projects/1/actionwords'}

    let(:create_url) {'https://hiptest.net/api/projects/1/actionwords'}
    let(:update_url) { "https://hiptest.net/api/projects/1/actionwords/#{resource_id}" }

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

  context 'api_exists?' do
    let(:api){ double("API::Hiptest") }
    let(:find_url) {'https://hiptest.net/api/projects/1/actionwords'}
    let(:find_results) {
      {
        'data' => find_data
      }
    }
    let(:actionword ) {
      Models::Actionword.new('My first actionword')
    }

    context 'when only one result is returned' do
      let(:find_data) {
        [
          {
            'type' => 'actionwords',
            'id' => '1664',
            'attributes' => {
              'name' => 'My first actionword (2)'
            }
          }
        ]
      }

      it 'checks that the actionword name is the beginning of the returned result' do
        allow(api).to receive(:get).with(URI(find_url)).and_return(find_results)
        actionword.class.api = api

        expect(actionword.api_exists?).to be true
        expect(actionword.id).to eq(find_data.first['id'])
      end
    end

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

      it 'uses the first result which name starts with the actionword name' do
        allow(api).to receive(:get).with(URI(find_url)).and_return(find_results)
        actionword.class.api = api

        expect(actionword.api_exists?).to be true
        expect(actionword.id).to eq(find_data[1]['id'])
      end
    end
  end

  context "when saving" do
    let(:api){ double("API::Hiptest") }
    let(:create_url) {'https://hiptest.net/api/projects/1/actionwords'}
    let(:find_url) { "#{create_url}/find_by_tags?key=JIRA&value=PLOP-1" }

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
      allow(api).to receive(:get).with(URI(create_url)).and_return({ 'data' => []})
      allow(api).to receive(:get).with(URI(find_url)).and_return({ 'data' => []})
      allow(api).to receive(:post).with(URI(create_url), create_data).and_return(created_data)
      actionword.class.api = api

      allow(actionword).to receive(:update)
      expect(actionword.api_exists?).to be false

      actionword.save
      expect(actionword).to have_received(:update)
    end
  end
end

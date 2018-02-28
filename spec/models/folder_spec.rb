require './lib/models/folder'

require './spec/models/models_shared'

describe Models::Folder do
  it_behaves_like 'a model' do
    let(:api) { double(API::Hiptest) }
    let(:an_existing_object ) { Models::Folder.new('My number one folder') }
    let(:an_unknown_object ) { Models::Folder.new('My other folder') }

    let(:resource_id) { 1664 }

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My number one folder',
            'parent-id': nil
          }
        }
      }
    }

    let(:update_data) {
      {
        :data=> {
          :attributes=> {
            :name=>"My number one folder",
            :"parent-id"=>nil
          },
          :id=>"1664",
          :type=>"folders",
        }
      }
    }

    let(:created_data) {
      {
        type: 'folders',
        id: '1664',
        attributes: {
          name: 'My number one folder'
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'folders',
          'id' => '1664',
          'attributes' => {
            'name' => 'My number one folder'
          }
        }
      ]
    }

  end
end

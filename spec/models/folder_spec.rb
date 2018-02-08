require './lib/models/folder'

require './spec/models/models_shared'

describe Models::Folder do
  it_behaves_like 'a model' do
    let(:an_existing_object ) { Models::Folder.new('My number one folder') }
    let(:an_unknown_object ) { Models::Folder.new('My other folder') }

    let(:find_url) {'https://hiptest.net/api/projects/1/folders'}
    let(:create_url) {'https://hiptest.net/api/projects/1/folders'}
    let(:update_url) {'https://hiptest.net/api/projects/1/folders/1664'}

    let(:create_data) {
      {
        data: {
          attributes: {
            name: 'My number one folder'
          }
        }
      }
    }
    let(:update_data) { create_data }

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
          'type' => 'object',
          'id' => '1664',
          'attributes' => {
            'name' => 'My number one folder'
          }
        }
      ]
    }

  end
end
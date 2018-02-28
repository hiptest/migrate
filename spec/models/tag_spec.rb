require './lib/models/tag'

require './spec/models/models_shared'

describe Models::Tag do
  it_behaves_like 'a model' do
    let(:api) { double("API::Hiptest") }
    let(:resource_type) { "scenarioTag" }

    let(:an_existing_object ) {
      Models::Tag.new('existing_key')
    }
    let(:an_unknown_object ) {
      Models::Tag.new('unknown_key')
    }

    let(:resource_id) { 1664 }

    let(:create_data) {
      {
        data: {
          attributes: {
            key: 'existing_key',
            value: '',
          }
        }
      }
    }

    let(:update_data) {
      {
        data: {
          id: '1664',
          type: 'tags',
          attributes: {
            key: 'existing_key',
            value: '',
          }
        }
      }
    }

    let(:created_data) {
      {
        'type' => 'tags',
        'id' => '1664',
        'attributes' => {
          'key' => 'existing_key',
          'value' => '',
        }
      }
    }

    let(:find_data) {
      [
        {
          'type' => 'scenarios',
          'id' => '1664',
          'attributes' => {
            'key' => 'existing_key',
            'value' => '',
          }
        }
      ]
    }
  end

  describe '#api_identical?' do
    it 'checks equality between instance and json response' do
      tag = Models::Tag.new('key', 'value')
      json_response = {
        'attributes' => {
          'key' => tag.key,
          'value' => tag.value,
        }
      }
      expect(tag.api_identical?(json_response)).to be_truthy
      expect(tag.api_identical?({})).to be_falsy
      expect(tag.api_identical?('attributes' => {'key' => tag.key, 'value' => 'plop'})).to be_falsy
      expect(tag.api_identical?('attributes' => {'key' => 'plop', 'value' => tag.value})).to be_falsy
    end
  end
end

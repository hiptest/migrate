require 'spec_helper'

shared_examples "a model" do

  HIPTEST_API_URI = 'https://hiptest.net/api'
  ENV['HT_PROJECT'] = "1"

  let(:an_existing_object ) {}
  let(:an_unknown_object ) {}

  let(:find_url) {'https://hiptest.net/project/1/find_stuff'}
  let(:create_url) {'https://hiptest.net/project/1/object_type'}
  let(:update_url) {'https://hiptest.net/project/1/object_type/1664'}

  let(:create_data) {
    {
      data: {
        attributes: {
          name: an_unknown_object.name
        }
      }
    }
  }
  let(:update_data) { create_data }

  let(:find_data) {
    [
      {type: 'object', id: '1', attributes: {name: 'Something'}}
    ]
  }

  let(:find_results) {
    {
      'data' => find_data
    }.to_json
  }

  let(:created_data) {
    {
      'type' => 'object',
      'id' => '1',
      'attributes' => {
        'name' => 'something'
      }
    }
  }

  let(:create_result) {
    {
      'data' => created_data
    }.to_json
  }

  context 'api_exists?' do
    it 'contacts Hiptest via the APIs to find a matching element' do
      with_stubbed_request(find_url) do
        expect(an_existing_object.api_exists?).to have_requested(:get, find_url)
      end
    end

    it 'returns true and update the ID of the element when a maching element is found' do
      expect(an_existing_object.id).to be nil

      with_stubbed_request(find_url, find_results) do
        expect(an_existing_object.api_exists?).to be true
        expect(an_existing_object.id).to eq(find_data.first['id'])
      end
    end

    it 'uses api_identical? to find matching element' do
      with_stubbed_request(find_url, find_results) do
        allow(an_existing_object).to receive(:api_identical?)
        an_existing_object.api_exists?
        expect(an_existing_object).to have_received(:api_identical?)
      end
    end

    it 'when a matching element is not found, it returns false and the id of the element is not updated' do
      expect(an_unknown_object.id).to be nil

      with_stubbed_request(find_url, find_results) do
        expect(an_unknown_object.api_exists?).to be false
        expect(an_unknown_object.id).to be nil
      end
    end
  end

  context 'save' do
    it 'it checks via the APIs if an object exists on Hiptest' do
      with_stubbed_request(/.*hiptest.net.*/, find_results) do
        expect(an_existing_object.save).to have_requested(:get, find_url)
      end
    end

    it 'it creates the object on Hiptest if it is unknown' do

      stub_request(:get, find_url).to_return(body: {data: []}.to_json, status: 200)
      stub_request(:post, create_url).to_return(body: create_result, status: 200)
      stub_request(:patch, update_url).to_return(body: find_results, status: 200)

      expect(an_existing_object.save).to have_requested(:post, create_url)

    end

    it 'after creation, after_create and after_save are called' do
      stub_request(:get, find_url).to_return(body: {data: []}.to_json, status: 200)
      stub_request(:post, create_url).to_return(body: create_result, status: 200)
      stub_request(:patch, update_url).to_return(body: find_results, status: 200)

      allow(an_existing_object).to receive(:after_create)
      allow(an_existing_object).to receive(:after_save)

      an_existing_object.save

      expect(an_existing_object).to have_received(:after_create)
      expect(an_existing_object).to have_received(:after_save)
    end

    it 'it updates the object on Hiptest if it exists' do
      stub_request(:get, find_url).to_return(body: find_results, status: 200)
      stub_request(:patch, update_url).to_return(body: find_results, status: 200)

      expect(an_existing_object.save).to have_requested(:patch, update_url)
    end

    it 'after updating the object, after_update and after_save are called' do
      stub_request(:get, find_url).to_return(body: find_results, status: 200)
      stub_request(:patch, update_url).to_return(body: find_results, status: 200)

      allow(an_existing_object).to receive(:after_update)
      allow(an_existing_object).to receive(:after_save)

      an_existing_object.save

      expect(an_existing_object).to have_received(:after_update)
      expect(an_existing_object).to have_received(:after_save)
    end
  end
end

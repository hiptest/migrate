require 'spec_helper'

shared_examples "a model" do

  HIPTEST_API_URI = ENV['HT_URI'] || 'https://hiptest.net/api'
  ENV['HT_PROJECT'] = "1"
  
  let(:api){ raise NotImplementedError }

  let(:an_existing_object ) { raise NotImplementedError }
  let(:an_unknown_object ) { raise NotImplementedError }

  let(:find_url) { raise NotImplementedError }
  let(:query_that_found) { '' }
  let(:query_that_not_found) { '' }
  let(:create_url) { raise NotImplementedError }
  let(:update_url) { raise NotImplementedError }
  
  let(:resource_id) { raise NotImplementedError }

  let(:create_data) {
    {
      'data' => {
        'attributes' => {
          'name' => an_unknown_object.name,
          'description' => "",
          'folder-id' => nil
        }
      }
    }
  }
  
  let(:update_data) { raise NotImplementedError }

  let(:find_data) {
    raise NotImplementedError
  }

  let(:find_results) {
    {
      'data' => find_data
    }
  }

  let(:created_data) {
    raise NotImplementedError
  }

  let(:create_result) {
    {
      'data' => created_data
    }
  }

  context 'when calling api_exists?' do
    before do
      url = find_url + query_that_found
      allow(api).to receive(:get).with(URI(url)).and_return(find_results)
      an_existing_object.class.api = api
    end
    
    it 'returns true and update the ID of the element when a maching element is found' do
      expect(an_existing_object.id).to be nil
      
      expect(an_existing_object.api_exists?).to be true
      expect(an_existing_object.id).to eq(find_data.first['id'])
    end

    it 'uses api_identical? to find matching element' do
      allow(an_existing_object).to receive(:api_identical?)
      an_existing_object.api_exists?
      expect(an_existing_object).to have_received(:api_identical?)
    end

    it 'when a matching element is not found, it returns false and the id of the element is not updated' do
      not_found_url = find_url + query_that_not_found
      allow(api).to receive(:get).with(URI(not_found_url)).and_return({'data' => []})
      an_existing_object.class.api = api
      
      expect(an_unknown_object.id).to be nil
      expect(an_unknown_object.api_exists?).to be false
      expect(an_unknown_object.id).to be nil
    end
  end

  context 'when saving' do
    before do
      @url = find_url + query_that_found
      @api = spy(API::Hiptest)
      allow(@api).to receive(:get).with(URI(create_url)).and_return({'data' => []})
      allow(@api).to receive(:get).with(URI(@url)).and_return({'data' => []})
      allow(@api).to receive(:post).with(URI(create_url), create_data).and_return(create_result)
      allow(@api).to receive(:patch).with(URI(update_url), update_data).and_return(find_results)
      allow(@api).to receive(:get_scenario).with("1", "#{resource_id}").and_return({
        'data' => {
          'attributes' => {
            'name' => an_existing_object.name
          }
        }
      })
      an_existing_object.class.api = @api
    end
    
    it 'it creates the object on Hiptest if it is unknown' do
      an_existing_object.save
      expect(@api).to have_received(:post)
    end

    it 'after creation, after_create and after_save are called' do
      allow(an_existing_object).to receive(:after_create)
      allow(an_existing_object).to receive(:after_save)

      an_existing_object.save

      expect(an_existing_object).to have_received(:after_create)
      expect(an_existing_object).to have_received(:after_save)
    end

    it 'it updates the object on Hiptest if it exists' do
      allow(@api).to receive(:get).with(URI(@url)).and_return(find_results)
      
      an_existing_object.save
      expect(@api).to have_received(:patch)
    end
    
    it 'before updating the object, before_update is called' do
      allow(an_existing_object).to receive(:api_exists?).and_return(true)
      allow(@api).to receive(:patch)
      allow(an_existing_object).to receive(:before_update)
      
      an_existing_object.update
      
      expect(an_existing_object).to have_received(:before_update)
    end

    it 'after updating the object, after_update and after_save are called' do
      allow(@api).to receive(:get).with(URI(@url)).and_return(find_results)
      
      allow(an_existing_object).to receive(:after_update)
      allow(an_existing_object).to receive(:after_save)

      an_existing_object.save

      expect(an_existing_object).to have_received(:after_update)
      expect(an_existing_object).to have_received(:after_save)
    end
  end
end

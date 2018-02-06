shared_examples "a model" do
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

  let(:find_results) {
    {
      data: [
        {type: 'object', id: '1', attributes: {name: 'Something'}}
      ]
    }.to_json
  }

  context 'api_exists?' do
    xit 'contacts Hiptest via the APIs to find a matching element' do
      expect {an_existing_object.api_exists?}.to have_contacted(find_url)
    end

    xit 'when a matching element is found, it returns true and the id of the element is updated' do
      expect(an_existing_object).to be nil
      expect(an_existing_object.api_exists?).to be true
      expect(an_existing_object).to be 1664
    end

    xit 'when a matching element is not found, it returns false and the id of the element is not updated' do
      expect(an_existing_object).to be nil
      expect(an_existing_object.api_exists?).to be false
      expect(an_existing_object).to be nil
    end
  end

  context 'save' do
    xit 'it checks via the APIs if an object exists on Hiptest' do
      expect {an_existing_object.save}.to have_contacted(find_url)
    end

    xit 'it creates the object on Hiptest if it is unknown' do
      expect {an_unknown_object.save}.to have_contacted(create_url)
        .with_method('POST')
        .with_data(create_data)
    end

    xit 'after creation, after_create and after_save are called' do
      expect {an_unknown_object.save}.to have_called(:after_create, :after_save)
    end

    xit 'it updates the object on Hiptest if it exists' do
      expect {an_existing_object.save}.to have_contacted(update_url)
        .with_method('PATCH')
        .with_data(update_data)
    end

    xit 'after updating the object, after_update and after_save are called' do
      expect {an_unknown_object.save}.to have_called(:after_update, :after_save)
    end
  end
end

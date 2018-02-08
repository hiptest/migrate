require_relative '../../lib/api/api'
require 'webmock/rspec'

RSpec.describe API::Hiptest, 'Base' do
  let(:access_token){ "il_se_leve_tot_ken" }
  let(:client){ "cli_a_la_3eme_personnne_du_pluriel" }
  let(:uid){ "ken@hiptest.net" }
  
  before do
    API::Hiptest.base_url= "https://hiptest.net"
  end
  
  
  context "when configuring" do
    let(:password){ "s3cr3t_password" }
    
    
    it "has hiptest.net by default" do
      expect(API::Hiptest.base_url).to eq "https://hiptest.net"
    end
    
    
    it "can be updated to use another base_url by default" do
      API::Hiptest.new(base_url: "http://localhost")
      expect(API::Hiptest.base_url).to eq "http://localhost"
    end
    
    
    it "configure API when use #authenticate" do
      stub_request(:post, 'https://hiptest.net/api/auth/sign_in')
        .with(body: {
          email: uid,
          password: password
        }.to_json)
        .to_return(status: 200, headers: {
          "access-token": access_token,
          "client": client,
          "uid": uid
        })
      
      API::Hiptest.authenticate(uid, password)
      
      expect(API::Hiptest.configuration.access_token).not_to be_empty
      expect(API::Hiptest.configuration.client).not_to be_empty
      expect(API::Hiptest.configuration.uid).not_to be_empty
    end
    
    
    it "configure API::Hiptest with block using #configure" do
      API::Hiptest.configure do |config|
        config.access_token = access_token
        config.client = client
        config.uid = uid
      end
      
      expect(API::Hiptest.configuration.access_token).to eq access_token
      expect(API::Hiptest.configuration.client).to eq client
      expect(API::Hiptest.configuration.uid).to eq uid
    end
    
    
    it "configure API::Hiptest by its constructor" do
      API::Hiptest.new(access_token: access_token, client: client, uid: uid)
      
      expect(API::Hiptest.configuration.access_token).to eq access_token
      expect(API::Hiptest.configuration.client).to eq client
      expect(API::Hiptest.configuration.uid).to eq uid
    end
    
    
    context 'with wrong credentials' do
      let(:wrong_password) { "oups" }
      
      
      it 'raise Authentication failed' do
        stub_request(:post, 'https://hiptest.net/api/auth/sign_in')
          .with(body: {
            email: uid,
            password: wrong_password
          }.to_json)
          .to_return(status: 401, body: {
            errors: [
              "Invalid login credentials. Please try again."
            ]
          }.to_json)
        
        expect {
          API::Hiptest.authenticate(uid, wrong_password)
        }.to raise_error 'Authentication failed'
      end
    end
  end
end
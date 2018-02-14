require './lib/env'

require './lib/api/authentication'
require './lib/api/configuration'
require './lib/api/routing/router'

require 'net/http'
require 'pry'
require 'colorize'

module API
  class Hiptest
    @base_url = ENV["HT_URI"] || "https://hiptest.net/api"
    @use_ssl = @base_url.start_with?('https')
    
    
    include API::Configuration
    
    
    class << self
      attr_accessor :configuration, :base_url, :use_ssl
    end
    
    def self.arrange_base_url!
      self.base_url = self.arrange_base_url
    end
    
    def self.arrange_base_url
      base_url = self.base_url
      unless base_url.end_with?('/api')
        if base_url.end_with?('/')
          base_url += 'api'
        else
          base_url += '/api'
        end
      end
      base_url
    end
    
    
    def initialize(access_token: nil, client: nil, uid: nil, base_url: nil)
      self.class.configuration.access_token = access_token if access_token
      self.class.configuration.client = client if client
      self.class.configuration.uid = uid if uid
      self.class.base_url = base_url if base_url
    end
    
    
    include API::Authentication
    include API::Routing
    
    
    # private
    
    def get(uri)
      req = Net::HTTP::Get.new(uri)
      send_request(uri, req)
    end

    def post(uri, body)
      req = Net::HTTP::Post.new(uri)
      req.body = body.to_json

      send_request(uri, req)
    end

    def patch(uri, body)
      req = Net::HTTP::Patch.new(uri)
      req.body = body.to_json

      send_request(uri, req)
    end
    
    def delete(uri)
      req = Net::HTTP::Delete.new(uri)
      send_request(uri, req)
    end
    
    def send_request(uri, req)
      res = nil

      add_auth_header_to_request(req)
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => self.class.use_ssl) do |http|
        http.request(req)
      end

      if response.code == "200"
        res = JSON.parse(response.body) unless response.body.empty?
      else
        if response.code == "429"
          puts "API limit rate exceeded, sleeping for a while".blue
          sleep 310
          puts "Ok, let's start again".blue
          return send_request(uri, req)
        end
        
        puts JSON.parse(response.body).dig('error').red
        raise response.message
      end

      res
    end
  end
end



def configure_api_from_env
  env_vars = get_env_variables
  API::Hiptest.configure do |config|
    config.access_token = env_vars[:access_token]
    config.client = env_vars[:client]
    config.uid = env_vars[:uid]
  end
end
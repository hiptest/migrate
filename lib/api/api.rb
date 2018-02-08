require './lib/env'

require './lib/api/authentication'
require './lib/api/configuration'
require './lib/api/routes'

require 'net/http'
require 'pry'

module API
  class Hiptest
    @base_url = ENV["HT_BASE_URL"] || "https://hiptest.net"
    @use_ssl = @base_url.start_with?('https')
    
    
    include API::Configuration
    
    
    class << self
      attr_accessor :configuration, :base_url
      attr_reader :use_ssl
    end
    
    def self.arrange_base_url!
      self.base_url = self.arrange_base_url
    end
    
    def self.arrange_base_url
      base_url = self.base_url
      unless base_url.end_with?('/api/')
        if base_url.end_with?('/api')
          base_url += '/'
        elsif base_url.end_with?('/')
          base_url += 'api/'
        else
          base_url += '/api/'
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
    include API::Routes
    
    
    # private
    
    def get(uri)
      req = Net::HTTP::Get.new(uri)
      send_request(uri, req)
    end

    def post(uri, body)
      req = Net::HTTP::Post.new(uri.path)
      req.body = body

      send_request(uri, req)
    end

    def patch(uri, body)
      req = Net::HTTP::Patch.new(uri.path)
      req.body = body

      send_request(uri, req)
    end
    
    def delete(uri)
      req = Net::HTTP::Delete.new(uri.path)
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
        if response.message == 'Too Many Requests'
          puts "API limit rate exceeded, sleeping for a while"
          sleep 310
          puts "Ok, let's start again"
          return send_request(uri, req)
        end
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

def get(uri)
  api = API::Hiptest.new
  api.get(uri)
end

def post(uri, body)
  api = API::Hiptest.new
  api.post(uri)
end

def patch(uri, body)
  api = API::Hiptest.new
  api.patch(uri)
end

def delete(uri)
  api = API::Hiptest.new
  api.delete(uri)
end


# Api usage:
# 
# API::Hiptest.configure do |config|
#   config.access_token = "xxxxxxxxx"
#   config.client = "xxxxxxxxx"
#   config.uid = "bidiboup@hiptest.net"
# end
#
# OR
#
# API::Hiptest.authenticate("bidiboup@hiptest.net", "s3cr3t_p@ssw0rd")
#
# Then
# ht_api = API::Hiptest.new
# OR if you want to configure by the API contructor
# ht_api = API::Hiptest.new(access_token, client, uid)
# 
# ht_api.get_projects
# ht_api.get_project(project_id)
# 
# ht_api.get_folders(project_id)
# ht_api.get_folder(project_id, folder_id)
# ht_api.create_folder(project_id, folder_data)
# ht_api.update_folder(project_id, folder_id, folder_data)
# ht_api.delete_folder(project_id, folder_id)
# 
# ht_api.get_scenarios(project_id)
# ht_api.get_scenario(project_id, scenario_id)
# ht_api.create_scenario(project_id, scenario_data)
# ht_api.update_scenario(project_id, scenario_id, scenario_data)
# ht_api.delete_scenario(project_id, scenario_id)
# 
# ht_api.get_scenario_parameters(project_id, scenario_id)
# ht_api.get_scenario_parameter(project_id, scenario_id, parameter_id)
# ht_api.create_scenario_parameter(project_id, scenario_id, parameter_data)
# ht_api.update_scenario_parameter(project_id, scenario_id, parameter_id, parameter_data)
# ht_api.delete_scenario_parameter(project_id, scenario_id, parameter_id)
#
# ht_api.get_scenario_datasets(project_id, scenario_id)
# ht_api.get_scenario_dataset(project_id, scenario_id, dataset_id)
# ht_api.create_scenario_dataset(project_id, scenario_id, dataset_data)
# ht_api.update_scenario_dataset(project_id, scenario_id, dataset_id, dataset_data)
# ht_api.delete_scenario_dataset(project_id, scenario_id, dataset_id)
#
# ht_api.get_scenario_tags(resource_type, project_id, resource_id)
# ht_api.create_scenario_tag(resource_type, project_id, resource_id, tag_data)
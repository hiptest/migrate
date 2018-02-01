#!/usr/bin/env ruby
require 'pry'
require 'nokogiri'
require 'singleton'
require 'net/http'
require "uri"
require "json"

TO_TAG_NODES = [:link, :environment, :key, :priority, :status, :fixVersion, :labels, :versions, :issuekey]
ONLY_KEY_TAGS = []
HIPTEST_API_URI = 'https://hiptest.net/api'

###########################
#        CLASSES          #
###########################

class Project
  include Singleton

  attr_accessor :name, :description, :folders, :scenarios

  def initialize()
    @name = ''
    @description = ''
    @folders = []
    @scenarios = []
    @root_folder_id = nil
  end

  def api_create_or_update
    get_root_folder_id
    @scenarios.each do |scenario|
      scenario.folder_id = @root_folder_id
      scenario.api_create_or_update
    end

    @folders.each do |folder|
      folder.parent_id = @root_folder_id
      folder.api_create_or_update
    end
  end

  def get_root_folder_id
    uri = URI(HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/folders")
    res = get(uri)
    if res
      @root_folder_id = res['data'].select { |folder| folder.dig('attributes', 'parent-id').nil? }.first['id']
    end
  end
end


class Folder
  attr_accessor :id, :name, :scenarios, :parent_id, :api_path

  def initialize(name, scenarios = [])
    @id = nil
    @parent_id = nil
    @name = name
    @scenarios = scenarios
    @api_path = HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/folders"
    Project.instance.folders << self
  end

  def self.find_or_create_by_name(name)
    folder = Project.instance.folders.select{ |f| f.name == name }.first

    if folder.nil?
      folder = Folder.new(name)
    end

    folder
  end

  def api_create_or_update
    body = {
      data: {
        attributes: {
          name: @name,
          "parent-id": @parent_id
        }
      }
    }

    puts "-- Create/Update folder #{@name}"
    create_or_update(self, body, 'folders')

    @scenarios.each do |scenario|
      scenario.folder_id = @id
      scenario.api_create_or_update
    end
  end

  def api_exists?
    uri = URI(@api_path)
    exists?(self, uri, 'name', @name)
  end
end


class Scenario
  @@scenarios = []

  attr_accessor :id, :name, :project, :description, :steps, :parameters, :folder, :tags, :folder_id, :api_path

  def initialize(name, steps = [], description = '')
    @id = nil
    @folder_id = nil
    @name = name
    @description = description
    @steps = steps
    @parameters = []
    @datasets = []
    @tags = []
    @api_path = HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios"
    @@scenarios << self
  end

  def definition
    definition = "scenario '#{@name}' do\n"
    @steps.each do |step|
      steps = ""
      parameter = nil
      
      parameter = Parameter.find_or_create_by_name(step.dig(:data), self) unless step.dig(:data).empty?

      if step.dig(:step)
        action = " step { action: \"#{step.dig(:step) }"
        if parameter
          action << "${#{parameter.normalized_name}}"
        end
        action << "\" }\n"
        
        steps << action
      end
      if step.dig(:result)
        steps << " step { result: \"#{step.dig(:result)}\" }\n"
      end
    end

    definition << "\nend"
    definition
  end

  def api_create_or_update
    body = {
      data: {
        attributes: {
          name: @name,
          description: @description,
          "folder-id": @folder_id,
          definition: definition
        }
      }
    }

    puts "-- Create/Update scenario #{@name}"
    create_or_update(self, body, 'scenarios')
    
    @parameters.each do |parameter|
      parameter.api_create_or_update
    end

    @tags.each do |tag|
      tag.scenario_id = @id
      tag.api_create_or_update
    end
  end

  def self.find_by_name(name)
    @@scenarios.select{ |sc| sc.name == name }.first
  end

  def self.find(id)
    @@scenarios.select{ |sc| sc.id == id }.first
  end

  def api_exists?
    uri = URI(HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios")
    exists?(self, uri, 'name', @name)
  end
end

class Parameter
  @@parameters = []
  attr_reader :id, :name, :scenario, :api_path
  
  def initialize(name, scenario)
    @id = nil
    @name = name
    @scenario = scenario
    @api_path = HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{scenario.id}/parameters"
    @@parameters << self
  end
  
  def normalized_name
    "p#{scenario.parameters.count}"
  end
  
  def api_create_or_update
    body = {
      data: {
        attributes: {
          name: normalized_name
        }
      }
    }
    
    puts "-- Create/Update parameter #{@name}"
    create_or_update(self, body, 'parameters')
  end
  
  def api_exists?
    uri = URI(HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{scenario.id}/parameters")
    exists?(self, uri, 'name', @name)
  end
  
  def self.find_or_create_by_name(name, scenario)
    param = @@parameters.select{|p| p.name == name && p.scenario.name == scenario.name}.first
    
    if param.nil?
      param = Parameter.new(name, scenario)
      scenario.parameters << param
    end
    param
  end
end

class Dataset
  # code
end

class Tag
  attr_accessor :id, :key, :value, :api_path
  attr_reader :scenario_id

  def initialize(key, value = '')
    @id = nil
    @key = key
    @value = value
    @scenario_id = nil
    @api_path = nil
  end

  def scenario_id=(scenario_id)
    @scenario_id = scenario_id
    @api_path = HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{@scenario_id}/tags"
  end

  def api_create_or_update
    # TODO: GET back to work!
    body = {
      data: {
        attributes: {
          key: @key,
          value: @value
        }
      }
    }

    puts "-- Create tag #{@key}:#{@value}"
    create_or_update(self, body, 'tags')
  end

  def api_exists?
    exist = false
    res = get(URI(@api_path))

    if res and res['data'].any?
      res['data'].each do |r|
        if r.dig('attributes', 'key') == @key.to_s and r.dig('attributes', 'value') == @value
          exist = true
          @id = r.dig('id')
        end
      end
    end

    exist
  end
end



###########################
#       API REQUESTS      #
###########################

def get(uri)
  req = Net::HTTP::Get.new(uri.path)
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

def send_request(uri, req)
  res = nil

  add_auth_header_to_request(req)
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
    http.request(req)
  end

  if response.code == "200"
    res = JSON.parse(response.body)
  else
    if response.message == 'Too Many Requests'
      puts "API limit rate exceeded, sleeping for a while"
      sleep 600
      puts "Ok, let's start again"
      return send_request(uri, req)
    end
    puts response.message
  end

  res
end

def exists?(resource, uri, attribute_name, attribute)
  exist = false
  res = get(uri)

  if res and res['data'].any?
    res['data'].each do |r|
      if r.dig('attributes', attribute_name) == attribute
        exist = true
        resource.id = r.dig('id')
      end
    end
  end

  exist
end

def create_or_update(resource, body, resource_type = nil)
  res = nil

  if resource.api_exists?
    resource.api_path += "/#{resource.id}"
    uri = URI(api_path)

    body[:data][:attributes].delete(:name)
    body[:data][:type] = resource_type
    body[:data][:id] = resource.id

    res = patch(uri, body.to_json)
  else
    uri = URI(resource.api_path)
    res = post(uri, body.to_json)
    if res
      resource.id = res.dig('data', 'id')
    else
      STDERR.puts "Error while creating/updating #{resource_type} with : #{body}"
    end
  end
end

def add_auth_header_to_request(request)
  headers.each do |name, value|
    request[name] = value
  end
end

def headers
  env_variables = get_env_variables
  {
    "Content-Type" => "application/json",
    "Accept" => "application/vnd.api+json; version=1",
    "access-token" => "#{env_variables[:access_token]}",
    "client" => "#{env_variables[:client]}",
    "uid" => "#{env_variables[:uid]}"
  }
end

def get_env_variables
  {
    access_token: ENV['HT_ACCESS_TOKEN'],
    client: ENV['HT_CLIENT'],
    uid: ENV['HT_UID'],
    project_id: ENV['HT_PROJECT']
  }
end

def check_env_variables
  env_var_names = ['HT_ACCESS_TOKEN', 'HT_CLIENT', 'HT_UID', 'HT_PROJECT']
  is_errored = false

  env_var_names.each do |env_var|
    if ENV[env_var].nil?
      is_errored = true
      missing_env(env_var)
    end
  end

  if is_errored
    puts
    help
    exit(1)
  end
end


###########################
#        HELPERS          #
###########################

def missing_env(var_name)
  puts "#{var_name} environment variable is missing, please export it to push to Hiptest."
end

def help
  puts "Usage"
  puts "./migrate_zephyr.rb file1.xml file2.xml"
  puts
  puts "Some environment variables are required to push your project to Hiptest. Please export them in your terminal session or specify them before the script call."
  puts "\tHT_ACCESS_TOKEN:\tYou may find it in your Hiptest profile page"
  puts "\tHT_CLIENT:\t\tYou may find it in your Hiptest profile page"
  puts "\tHT_UID:\t\t\tYou may find it in your Hiptest profile page"
  puts "\tHT_PROJECT:\t\tYou may find it in the Url of your project. http://hiptest.net/app/projects/<project_id>"
  puts
  puts "Example: HT_ACCESS_TOKEN=xxxxxx HT_CLIENT=xxxxxx HT_UID=xxxxxx HT_PROJECT=xxxx ./migrate_zephyr.rb file1.xml file2.xml"
end

def parse_files(paths)
  files = []

  paths.each do |path|
    if File.file?(path) and path.end_with?('.xml')
      files << File.open(path) { |f| Nokogiri::XML(f)}
    end
  end

  files
end

def is_info_file? file_nodes
  file_nodes.xpath('//item').any? and file_nodes.xpath('//item/project').any? and file_nodes.xpath('//item/summary') and file_nodes.xpath('//item/type')[0].text === 'Test'
end

def is_execution_file? file_nodes
  file_nodes.xpath('//execution').any? and file_nodes.xpath('//execution/project').any? and file_nodes.xpath('//execution/testSummary').any?
end


def determinate_info_and_execution_files(files)
  infos, executions = nil

  files.each do |file|
    if is_info_file? file
      infos = file
    end

    if is_execution_file? file
      executions = file
    end
  end

  if infos.nil? or executions.nil?
    help
    exit(1)
  end

  [infos, executions]
end




###########################
#       PROCESSING        #
###########################

def process_infos(infos_nodes)
  tests_nodes = infos_nodes.xpath('//item')

  tests_nodes.each do |test_node|
    sc = {}

    test_node.children.each do |child|
      sc[child.name.to_sym] = child.content.strip
    end

    scenario = Scenario.find_by_name(sc[:summary])
    if scenario
      scenario.description= sc[:description]
    end
  end
end


def process_executions(executions_nodes)
  tests_nodes = executions_nodes.xpath('//execution')
  tests_nodes.each do |test_node|
    execution = {}
    steps = []

    test_node.element_children.each do |child|
      if child.name == 'teststeps'
        child.element_children.each do |step_node|
          test_step = {}
          step_node.element_children.each do |step_attribute|
            test_step[step_attribute.name.to_sym] = step_attribute.content.strip
          end
          steps << test_step
        end
      else
        execution[child.name.to_sym] = child.content.strip
      end
    end

    Project.instance.name = execution[:project]
    scenario = Scenario.new(execution[:testSummary], steps)

    TO_TAG_NODES.each do |tag|
      unless ONLY_KEY_TAGS.include? tag
        scenario.tags << Tag.new(tag, execution[tag]) unless execution[tag].nil? or execution[tag].empty?
      else
        scenario.tags << Tag.new(tag)
      end
    end

    folder = nil
    unless execution[:components].empty?
      folder = Folder.find_or_create_by_name(execution[:components])
      folder.scenarios << scenario
    else
      Project.instance.scenarios << scenario
    end
  end
end



###########################
#           MAIN          #
###########################

if __FILE__ == $0
  check_env_variables
  if ARGV.count == 2
    files = parse_files(ARGV)
    infos, executions = determinate_info_and_execution_files(files)
    process_executions(executions)
    process_infos(infos)
    Project.instance.api_create_or_update
  else
    help
    exit(1)
  end
end

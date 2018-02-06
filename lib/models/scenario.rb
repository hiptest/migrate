require './lib/models/model.rb'

module Models
  class Scenario < Model
    @@scenarios = []

    attr_accessor :id, :name, :project, :description, :steps, :parameters, :datasets, :folder, :tags, :folder_id, :api_path, :jira_id

    def initialize(name, steps = [], description = '')
      @id = nil
      @folder_id = nil
      @name = name
      @description = description
      @steps = steps
      @parameters = []
      @datasets = []
      @tags = []
      @jira_id = ''
      @@scenarios << self
    end

    def api_path
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios"
    end

    def compute_datatable(step)
      steps = ""
      parameter = nil

      unless step.dig(:data).empty?
        parameter = Parameter.find_or_create_by_data(@jira_id, step.dig(:data))
        Dataset.find_or_create_by_param(@jira_id, parameter.normalized_name, step.dig(:data))
      end

      if step.dig(:step)
        action = " step { action: \"#{step.dig(:step)}"
        if parameter
          action << " ${#{parameter.normalized_name}}"
        end
        action << "\" }\n"

        steps << action
      end

      result = step.dig(:result)&.strip
      if result && !result.empty?
        result_step = " step { result: \"#{result}"
        if parameter && step.dig(:step).empty?
          result_step << " ${#{parameter.normalized_name}}"
        end
        result_step << "\" }\n"

        steps << result_step
      end

      steps
    end

    def definition
      name = @name.gsub("'", %q(\\\'))
      definition = "scenario '#{name}' do\n"

      @steps.each do |step|
        definition << compute_datatable(step)
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
        parameter.compute_api_path
        parameter.api_create_or_update
      end

      @datasets.each do |dataset|
        dataset.compute_api_path
        dataset.api_create_or_update
      end

      @tags.each do |tag|
        tag.scenario_id = @id
        tag.api_create_or_update
      end
    end

    def self.find_by_name(name)
      @@scenarios.select { |sc| sc.name == name }.first
    end

    def self.find_by_jira_id(jira_id)
      @@scenarios.select{ |sc| sc.jira_id == jira_id }.first
    end

    def self.find(id)
      @@scenarios.select{ |sc| sc.id == id }.first
    end

    def api_exists?
      uri = URI(HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios")
      exists?(self, uri, 'name', @name)
    end
  end
end

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

    def api_data
      {
        data: {
          attributes: {
            name: @name,
            description: @description,
            "folder-id": @folder_id,
            definition: definition
          }
        }
      }
    end

    def after_create
      # Yep, we save it once again so the definition is updated correctly
      update
    end

    def after_save
      @parameters.each do |parameter|
        parameter.compute_api_path
        parameter.save
      end

      @datasets.each do |dataset|
        dataset.compute_api_path
        dataset.save
      end

      @tags.each do |tag|
        tag.scenario_id = @id
        tag.save
      end
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

    def self.find_by_name(name)
      @@scenarios.select { |sc| sc.name == name }.first
    end

    def self.find_by_jira_id(jira_id)
      @@scenarios.select{ |sc| sc.jira_id == jira_id }.first
    end

    def self.find(id)
      @@scenarios.select{ |sc| sc.id == id }.first
    end
  end
end

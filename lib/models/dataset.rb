require './lib/models/model.rb'
require './lib/models/scenario'

module Models
  class Dataset < Model
    @@datasets = []
    attr_accessor :id, :data, :scenario_jira_id, :api_path

    def initialize(scenario_jira_id)
      @data = data
      @scenario_jira_id = scenario_jira_id
      @data = {}
      @api_path = nil
      @@datasets << self
    end

    def api_path
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{scenario.id}/datasets"
    end

    def create_data
      {
        data: {
          attributes: {
            name: "",
            data: @data
          }
        }
      }
    end

    def data_type
      'datasets'
    end

    def api_identical?(result)
      result.dig('attributes', 'data').to_json == data.to_json
    end

    def scenario
      Scenario.find_by_jira_id(@scenario_jira_id)
    end

    def self.find_or_create_by_param(scenario_jira_id, parameter_name, data)
      scenario = Scenario.find_by_jira_id(scenario_jira_id)
      dataset = @@datasets.select{|ds| ds.scenario_jira_id == scenario.jira_id }.first

      unless dataset
        dataset = Dataset.new(scenario_jira_id)
        scenario.datasets << dataset
      end

      dataset.data[parameter_name.to_sym] = data

      dataset
    end
  end
end

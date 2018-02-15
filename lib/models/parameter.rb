require './lib/models/model.rb'

module Models
  class Parameter < Model
    @@parameters = []
    attr_accessor :id, :name, :data, :scenario_jira_id, :api_path

    def initialize(scenario_jira_id, data)
      @id = nil
      @name = nil
      @data = data
      @scenario_jira_id = scenario_jira_id
      @@parameters << self
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{scenario.id}/parameters"
    end

    def create_data
      {
        data: {
          attributes: {
            name: normalized_name
          }
        }
      }
    end

    def scenario
      Scenario.find_by_jira_id(@scenario_jira_id)
    end

    def normalized_name
      @name = "p#{scenario.parameters.count}" if @name.nil?
      @name
    end


    def api_identical?(result)
      result.dig('attributes', 'name') == normalized_name
    end

    def self.find_or_create_by_data(scenario_jira_id, data)
      scenario = Scenario.find_by_jira_id(scenario_jira_id)
      param = @@parameters.select{ |p| p.data == data && p.scenario_jira_id == scenario.jira_id }.first

      if param.nil?
        param = Parameter.new(scenario.jira_id, data)
        scenario.parameters << param
      end
      param
    end
  end
end

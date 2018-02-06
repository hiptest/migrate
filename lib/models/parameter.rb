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
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{scenario.id}/parameters"
    end

    def scenario
      Scenario.find_by_jira_id(@scenario_jira_id)
    end

    def normalized_name
      @name = "p#{scenario.parameters.count}" if @name.nil?
      @name
    end

    def api_create_or_update
      body = {
        data: {
          attributes: {
            name: normalized_name
          }
        }
      }

      puts "-- Create/Update parameter #{normalized_name}"
      create_or_update(self, body, 'parameters')
    end

    def api_exists?
      exist = false
      res = get(URI(@api_path))

      if res and res['data'].any?
        res['data'].each do |r|
          if r.dig('attributes', 'name') == normalized_name
            exist = true
            @id = r.dig('id')
          end
        end
      end

      exist
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

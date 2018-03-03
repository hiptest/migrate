require './lib/models/model.rb'

module Models
  class Tag < Model
    attr_accessor :id, :key, :value
    attr_reader :scenario_id

    def initialize(key, value = '')
      @id = nil
      @key = key
      @value = value
      @scenario_id = nil
    end

    def api_arguments
      [project_id, @scenario_id.to_s, @id.to_s]
    end

    def api_method
      "scenarioTag"
    end

    def scenario_id=(scenario_id)
      @scenario_id = scenario_id
    end

    def create_data
      {
        data: {
          attributes: {
            key: @key,
            value: @value
          }
        }
      }
    end

    def name
      "#{@key}:#{value}"
    end

    def api_identical?(json_response)
      json_response.dig('attributes', 'key') == @key.to_s &&
          json_response.dig('attributes', 'value') == @value
    end

    def api_exists?
      exist = false
      res = @@api.get_scenarioTags(project_id, @scenario_id)

      if res and res['data'].any?
        res['data'].each do |r|
          if api_identical?(r)
            exist = true
            @id = r.dig('id')
          end
        end
      end

      exist
    end
  end
end

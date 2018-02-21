require './lib/models/model.rb'

module Models
  class Tag < Model
    attr_accessor :id, :key, :value, :api_path
    attr_reader :scenario_id

    def initialize(key, value = '')
      @id = nil
      @key = key
      @value = value
      @scenario_id = nil
      @api_path = nil
    end
    
    def api_method
      "scenario_tag"
    end
    
    def api_arguments
      [ENV['HT_PROJECT'], @scenario_id.to_s, @id.to_s]
    end

    def scenario_id=(scenario_id)
      @scenario_id = scenario_id
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{@scenario_id}/tags"
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

    def api_exists?
      exist = false
      res = @@api.get_scenario_tags(ENV['HT_PROJECT'], @scenario_id)

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
end

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

    def scenario_id=(scenario_id)
      @scenario_id = scenario_id
    end

    def api_path
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/scenarios/#{@scenario_id}/tags"
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

    def data_type
      'tags'
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

require './lib/models/model.rb'

module Models
  class Actionword < Model
    @@actionwords = []

    attr_accessor :id, :name, :description, :api_path

    def initialize(name)
      @id = nil
      @name = name.gsub('"', %q(\\\'))
      @description = ''
      @@actionwords << self
    end

    def api_path
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/actionwords"
    end

    def create_data
      {
        data: {
          attributes: {
            name: @name,
            description: @description
          }
        }
      }
    end
    
    def update_data
      {
        data: {
          id: @id,
          type: 'actionwords',
          attributes: {
            description: @description,
            definition: definition
          }
        }
      }
    end
    
    def definition
      "actionword '#{@name}' (__free_text = \"\") do\nend"
    end
    
    def after_create(data)
      update
    end

    def api_exists_url
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/actionwords"
    end

    def api_identical?(result)
      result.dig('attributes', 'name').start_with?(@name.gsub('\\', ''))
    end
    
    def data_type
      'actionwords'
    end
    
    def self.find_by_name(name)
      @@actionwords.select { |aw| aw.name == name.gsub('"', %q(\\\')) }.first
    end
    
    def self.find_or_create_by_name(name)
      self.find_by_name(name) || Actionword.new(name)
    end
  end
end

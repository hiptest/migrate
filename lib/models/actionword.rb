require './lib/models/model'
require './lib/utils/string'

module Models
  class Actionword < Model
    @@actionwords = []

    attr_accessor :id, :name, :description, :api_path

    def initialize(name)
      @id = nil
      @name = name
      @description = ''
      @@actionwords << self
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/actionwords"
    end

    def create_data
      @name = find_unique_name(@name, @@api.get(URI(api_path))['data'].map {|sc| sc.dig('attributes', 'name')})
      
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
    
    def before_update
      if api_exists?
        res = @@api.get_actionword(ENV['HT_PROJECT'], @id)
        @name = res.dig('data', 'attributes', 'name').double_quotes_replaced.single_quotes_escaped.safe
      end
    end
    
    def after_create(data)
      update
    end

    def api_exists_url
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/actionwords"
    end

    def api_identical?(result)
      result.dig('attributes', 'name').start_with?(@name.gsub('\\', ''))
    end
    
    def self.find_by_name(name)
      @@actionwords.select { |aw| aw.name == name.double_quotes_replaced.single_quotes_escaped.safe }.first
    end
    
    def self.find_or_create_by_name(name)
      name = name.double_quotes_replaced.single_quotes_escaped.safe
      self.find_by_name(name) || Actionword.new(name)
    end
    
    def find_unique_name(current, existing)
      return current unless existing.include?(current)

      postfix = 0
      new_name = ''

      loop do
        postfix += 1
        new_name = "#{current} (#{postfix})"

        break unless existing.include?(new_name)
      end

      new_name
    end
    
    def formated_name
      #code
    end
  end
end

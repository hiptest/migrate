require './lib/models/model'
require './lib/utils/string'

module Models
  class Actionword < Model
    @@actionwords = []

    attr_accessor :id, :name, :description

    def initialize(name)
      @id = nil
      @name = name
      @description = ''
      @@actionwords << self
    end

    def create_data
      @name = find_unique_name(@name, @@api.get_actionwords(project_id)['data'].map {|sc| sc.dig('attributes', 'name')})

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
        res = @@api.get_actionword(project_id, @id)
        @name = res.dig('data', 'attributes', 'name').double_quotes_replaced.single_quotes_escaped
      end
    end

    def after_create(data)
      update
    end

    def api_identical?(result)
        result.dig('attributes', 'name').double_quotes_replaced.single_quotes_escaped == @name
    end

    def self.find_by_name(name)
      @@actionwords.select { |aw| aw.name == name.double_quotes_replaced.single_quotes_escaped }.first
    end

    def self.find_or_create_by_name(name)
      self.find_by_name(name) || Actionword.new(name.double_quotes_replaced.single_quotes_escaped)
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

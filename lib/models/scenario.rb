require './lib/models/model'
require './lib/models/actionword'
require './lib/utils/string'

module Models
  class Scenario < Model
    @@scenarios = []

    attr_accessor :id, :name, :description, :actionwords, :steps, :parameters, :datasets, :folder, :tags, :folder_id, :api_path, :jira_id

    def initialize(name, steps = [], description = '')
      @id = nil
      @folder_id = nil
      @name = name
      @description = description
      @steps = steps
      @actionwords = []
      @parameters = []
      @datasets = []
      @tags = []
      @jira_id = ''
      @@scenarios << self
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/scenarios"
    end

    def create_data
      @name = find_unique_name(@name, @@api.get(URI(api_path))['data'].map {|sc| sc.dig('attributes', 'name')})

      {
        data: {
          attributes: {
            name: @name,
            description: @description,
            "folder-id": @folder_id
          }
        }
      }
    end

    def update_data
      {
        data: {
          id: @id,
          type: 'scenarios',
          attributes: {
            description: @description,
            "folder-id": @folder_id,
            definition: definition
          }
        }
      }
    end

    def api_exists_url
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/scenarios/find_by_tags?key=JIRA&value=#{@jira_id}"
    end

    def api_identical?(result)
      result.dig('attributes', 'name').start_with?(@name)
    end

    def after_create(data)
      # Yep, we save it once again so the definition is updated correctly
      update
    end

    def before_update
      if api_exists?
        res = @@api.get_scenario(ENV['HT_PROJECT'], @id)
        @name = res.dig('data', 'attributes', 'name')
      end
    end

    def after_save(data)
      @actionwords.each do |actionword|
        actionword.save
      end

      @tags.each do |tag|
        tag.scenario_id = @id
        tag.save
      end
    end

    def compute_actionwords(step)
      steps = ""
      parameter = nil

      unless step.dig(:data).empty?
        parameter = step.dig(:data).as_enum_lines
        aw_name = step.dig(:step).empty? ? step.dig(:result) : step.dig(:step)
        aw = Actionword.find_by_name(aw_name)
      end

      action_step = step.dig(:step)&.strip
      if action_step && !action_step.empty?

        if parameter
          action = " call '#{aw.name}' (__free_text = \"#{parameter}\")\n"
        else
          action_step = action_step.double_quotes_replaced.single_quotes_escaped
          action = " step { action: \"#{action_step}\" }\n"
        end

        steps << action
      end

      result = step.dig(:result)&.strip
      if result && !result.empty?

        if parameter and step.dig(:step).empty?
          result_step = " call '#{aw.name}' (__free_text = '#{parameter}')\n"
        else
          result = result.double_quotes_replaced.single_quotes_escaped
          result_step = " step { result: \"#{result}\" }\n"
        end

        steps << result_step
      end

      steps
    end

    def definition
      name = @name.single_quotes_escaped
      definition = "scenario '#{name}' do\n"

      @steps.each do |step|
        definition << compute_actionwords(step)
      end

      definition << "end"
      definition
    end

    def add_unique_actionword(actionword)
      @actionwords << actionword unless @actionwords.map(&:name).include?(actionword.name)
    end

    def self.find_by_name(name)
      @@scenarios.select { |sc| sc.name == name.double_quotes_replaced.single_quotes_escaped }.first
    end

    def self.find_by_jira_id(jira_id)
      @@scenarios.select{ |sc| sc.jira_id == jira_id }.first
    end

    def self.find(id)
      @@scenarios.select{ |sc| sc.id == id }.first
    end

    def find_unique_name(current, existing)
      existing = existing.map(&:downcase)
      return current unless existing.include?(current.downcase)

      postfix = 0
      new_name = ''

      loop do
        postfix += 1
        new_name = "#{current} (#{postfix})"

        break unless existing.include?(new_name.downcase)
      end

      new_name
    end
  end
end

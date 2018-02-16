require './lib/models/model'
require './lib/utils/string'

module Models
  class TestRun < Model
    @@test_runs = []

    attr_accessor :id, :name, :description, :tests, :api_path

    def initialize(name, description = '')
      @id = nil
      @name = name
      @description = description
      @tests = []
      @@test_runs << self unless @@test_runs.map(&:name).include?(@name)
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/test_runs"
    end

    def create_data
      @name = find_unique_name(@name, @@api.get(URI(api_path))['data'].map {|tr| tr.dig('attributes', 'name')})

      {
        data: {
          attributes: {
            name: @name,
            description: @description
          }
        }
      }
    end

    def api_identical?(result)
      result.dig('attributes', 'name') == (@name)
    end
    
    def save
      unless api_exists?
        res = create
      else
        output("-- Test run #{@name} already exists (id: #{@id}).")
      end
      
      after_save(res)
      res
    end
    
    def after_save(data)
      push_results
    end
    
    def push_results
      #code
    end

    def self.find_by_name(name)
      @@scenarios.select { |sc| sc.name == name.single_quotes_escaped }.first
    end

    def self.find(id)
      @@scenarios.select{ |sc| sc.id == id }.first
    end
    
    def self.push_results
      @@test_runs.each do |test_run|
        test_run.save
      end
    end

    def find_unique_name(current, existing)
      existing = existing.map(&:tag_escaped)
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
  end
end

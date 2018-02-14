require './lib/models/model.rb'
require './lib/models/project'

module Models
  class Folder < Model
    attr_accessor :id, :name, :scenarios, :parent_id, :api_path

    def initialize(name, scenarios = [])
      @id = nil
      @parent_id = nil
      @name = name
      @scenarios = scenarios
      Project.instance.folders << self
    end

    def after_save(data)
      @scenarios.each do |scenario|
        scenario.folder_id = @id
        scenario.save
      end
    end

    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/folders"
    end

    def create_data
      {
        data: {
          attributes: {
            name: @name,
            "parent-id": @parent_id
          }
        }
      }
    end

    def data_type
      'folders'
    end

    def self.find_or_create_by_name(name)
      folder = Project.instance.folders.select{ |f| f.name == name }.first

      if folder.nil?
        folder = Folder.new(name)
      end

      folder
    end
  end
end

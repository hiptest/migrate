require './lib/models/model.rb'
require './lib/models/project'

module Models
  class Folder < Model
    attr_accessor :id, :name, :scenarios, :parent_id

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

    def self.find_or_create_by_name(name)
      folder = Project.instance.folders.find { |f| f.name == name }

      if folder.nil?
        folder = Folder.new(name)
      end

      folder
    end
  end
end

require './lib/models/model.rb'

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

    def api_path
      HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/folders"
    end

    def self.find_or_create_by_name(name)
      folder = Project.instance.folders.select{ |f| f.name == name }.first

      if folder.nil?
        folder = Folder.new(name)
      end

      folder
    end

    def api_create_or_update
      body = {
        data: {
          attributes: {
            name: @name,
            "parent-id": @parent_id
          }
        }
      }

      puts "-- Create/Update folder #{@name}"
      create_or_update(self, body, 'folders')

      @scenarios.each do |scenario|
        scenario.folder_id = @id
        scenario.api_create_or_update
      end
    end

    def api_exists?
      uri = URI(@api_path)
      exists?(self, uri, 'name', @name)
    end
  end
end

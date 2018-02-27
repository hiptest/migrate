require './lib/models/model.rb'
require 'singleton'

module Models
  class Project < Model
    include Singleton
    attr_accessor :name, :description, :folders, :scenarios, :root_folder_id

    def initialize()
      @id = ENV['HT_PROJECT']
      @name = ''
      @description = ''
      @folders = []
      @scenarios = []
      @root_folder_id = nil
    end

    def save
      get_root_folder_id
      @scenarios.each do |scenario|
        scenario.folder_id = @root_folder_id
        scenario.save
      end

      @folders.each do |folder|
        folder.parent_id = @root_folder_id
        folder.save
      end
    end

    def get_root_folder_id
      res = @@api.get_folders(@id)
      if res
        @root_folder_id = res['data'].select { |folder| folder.dig('attributes', 'parent-id').nil? }.first['id']
      end
    end
  end
end

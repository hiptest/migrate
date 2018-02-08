require './lib/models/model.rb'
require 'singleton'

module Models
  class Project < Model
    include Singleton
    attr_accessor :name, :description, :folders, :scenarios

    def initialize()
      @name = ''
      @description = ''
      @folders = []
      @scenarios = []
      @root_folder_id = nil
    end

    def api_path
      HIPTEST_API_URI + "/projects"
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
      uri = URI(HIPTEST_API_URI + "/projects/#{ENV['HT_PROJECT']}/folders")
      res = get(uri)
      if res
        @root_folder_id = res['data'].select { |folder| folder.dig('attributes', 'parent-id').nil? }.first['id']
      end
    end
  end
end

module API
  module Routing
    module Projects
      
      def get_projects
        uri = URI(self.class.base_url + "projects")
        get(uri)
      end
      
      def get_project(project_id)
        uri = URI(self.class.base_url + "projects/#{project_id}")
        get(uri)
      end
      
      def get_root_scenarios_folder(project_id)
        uri = URI(self.class.base_url + "projects/#{project_id}?include=scenarios-folder")
        get(uri)
      end
      
    end
  end
end
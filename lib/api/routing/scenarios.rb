module API
  module Routing
    module Scenarios
      
      def find_scenario_by_jira_id(project_id:, scenario_id:, jira_id:)
        uri = URI(API::Hiptest.base_url + "/projects/#{project_id}/scenarios/#{scenario_id}/find_by_tags?key=JIRA&value=#{jira_id}")
        get(uri)
      end
      
    end
  end
end
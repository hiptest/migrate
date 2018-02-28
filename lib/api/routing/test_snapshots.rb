module API
  module Routing
    module TestSnapshots

      def get_testSnapshot_including_scenario(project_id:, test_run_id:, test_snapshot_id:)
        uri = URI(API::Hiptest.base_url + "/projects/#{project_id}/test_runs/#{test_run_id}/test_snapshots/#{test_snapshot_id}?include=scenario")
        get(uri)
      end

    end
  end
end

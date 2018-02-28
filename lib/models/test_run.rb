require './lib/models/model'
require './lib/models/test_snapshot'
require './lib/utils/string'

module Models
  class TestRun < Model
    @@test_runs = []

    attr_accessor :id, :name, :description, :test_snapshots

    def initialize(name, description = '')
      @id = nil
      @name = name
      @description = description
      @test_snapshots = []
      @cache = {}
      @@test_runs << self unless @@test_runs.map(&:name).include?(@name)
    end

    def scenario_ids
      scenario_ids = []

      scenario_jira_ids = Models::Scenario.class_variable_get(:@@scenarios).map(&:jira_id)
      scenario_jira_ids.each do |jira_id|
        res = @@api.find_scenario_by_jira_id(project_id: ENV['HT_PROJECT'], jira_id: jira_id)
        scenario_ids << res['data'].first['id']
      end

      scenario_ids
    end

    def create_data
      @name = find_unique_name(@name, @@api.get_testRuns(ENV['HT_PROJECT'])['data'].map {|tr| tr.dig('attributes', 'name')})
      {
        data: {
          attributes: {
            name: @name,
            description: @description,
            scenario_ids: scenario_ids
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

      wait_for_test_run

      after_save(res)
      res
    end

    def after_save(data)
      fetch_tests
      push_results
    end

    def wait_for_test_run
      loop do
        break unless @@api.get_testRun_testSnapshots(ENV['HT_PROJECT'], @id).dig('data').count < Models::Scenario.count
        sleep 10
      end
    end

    def fetch_tests
      res = @@api.get_testRun_testSnapshots(ENV['HT_PROJECT'], @id)
      if res and res.dig('data').any?
        res.dig('data').each do |ts|
          @test_snapshots << Models::TestSnapshot.new(
            id: ts.dig('id'),
            name: ts.dig('attributes', 'name'),
            status: ts.dig('attributes', 'status'),
            test_run_id: @id,
            folder_snapshot_id: ts.dig('attributes', 'folder-snapshot-id')
          )
        end
      end
    end

    def push_results
      Models::TestSnapshot.process_results
      @test_snapshots.each do |ts|
        next if ts.is_already_pushed?
        scenario = ts.related_scenario

        unless @cache[scenario.object_id].nil?
          status = @cache[scenario.object_id][:status]
          author = @cache[scenario.object_id][:author]
          description = @cache[scenario.object_id][:description]

          ts.status = status
          ts.push_results(status, author, description)
        end
      end

      Models::TestSnapshot.clear_pushed_results if test_snapshots_are_all_pushed?
    end

    def test_snapshots_are_all_pushed?
      Models::TestSnapshot.process_results
      !@test_snapshots.map(&:is_already_pushed?).include?(false)
    end

    def self.push_results
      @@test_runs.each do |test_run|
        test_run.save
      end
    end

    def add_status_to_cache(scenario:, status:, author:, description: "")
      @cache[scenario.object_id] = {
        status: status,
        author: author,
        description: description
      }
    end

    def self.find_or_create_by_name(name)
      @@test_runs.select{ |tr| tr.name == name}.first || TestRun.new(name)
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

require './lib/models/model'
require 'colorize'

module Models
  class TestSnapshot < Model
    @@results_path = ""
    @@pushed_results = []

    attr_accessor :id, :name, :status, :test_run_id, :folder_snapshot_id

    def initialize(id:, name:, status:, test_run_id:, folder_snapshot_id: nil)
      @id = id
      @name = name
      @status = status
      @test_run_id = test_run_id
      @@results_path = "./tmp/#{test_run_id}_results"
      @folder_snapshot_id = folder_snapshot_id
      @related_scenario_jira_id = nil
    end

    def api_arguments
      [ENV['HT_PROJECT'], @test_run_id.to_s, @id.to_s]
    end

    def related_scenario
      unless @related_scenario_jira_id
        scenario_res = @@api.get_testSnapshot(ENV['HT_PROJECT'], @test_run_id, @id, include: 'scenario')
        related_scenario_id = scenario_res.dig('included').first.dig('id')

        tags_res = @@api.get_scenarioTags(ENV['HT_PROJECT'], related_scenario_id)
        @related_scenario_jira_id = tags_res.dig('data').select{|tag| tag.dig('attributes', 'key') == 'JIRA'}.first.dig('attributes', 'value')
      end

      Models::Scenario.find_by_jira_id(@related_scenario_jira_id)
    end

    def create_data
      {
        data: {
          attributes: {
            name: @name,
            status: @status
          }
        }
      }
    end

    def update_data
      {
        data: {
          id: @id,
          type: "test-snapshots",
          attributes: {
            status: @status
          }
        }
      }
    end

    def result_data(status, author, description)
      {
        data: {
          type: "test-results",
          attributes: {
            status: status,
            'status-author': author,
            description: description
          }
        }
      }
    end

    def push_results(status, author, description = "")
      status, color = Models::TestSnapshot.status_map(status)

      output("-- #{@name} => " + status.send(color))
      begin
        @@api.create_testResult(ENV['HT_PROJECT'], @test_run_id, @id, data: result_data(status, author, description))
        File.open(@@results_path, "a") do |line|
          line.puts @id
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        puts 'Something bad happened'.red
        puts e
      end
    end

    def is_already_pushed?
      @@pushed_results.select{ |ts_id| ts_id == @id}.any?
    end

    def self.process_results
      @@pushed_results = []
      if File.exist?(@@results_path)
        File.open(@@results_path, 'r').each do |line|
          @@pushed_results << line.sub("\n", '')
        end
      end
    end

    def self.clear_pushed_results
      if File.exist?(@@results_path)
        File.delete(@@results_path)
      end
    end

    def self.status_map(status)
      case status
      when /pass/
        color = "green"
        mapped_status = "passed"
      when /unexecuted/
        color = "uncolorize"
        mapped_status = "undefined"
      when /fail/
        color = "red"
        mapped_status = "failed"
      when /deferred/
        color = "blue"
        mapped_status = "skipped"
      when /blocked/
        color = "magenta"
        mapped_status = "blocked"
      when /wip/
        color = "yellow"
        mapped_status = "wip"
      else
        color = "black"
        mapped_status = status
      end

      [mapped_status, color]
    end
  end
end

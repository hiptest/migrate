require './lib/models/model'
require 'colorize'

module Models
  class TestSnapshot < Model
    @@results_path = "./results.txt"
    @@pushed_results = []
    
    attr_accessor :id, :name, :status, :test_run_id, :folder_snapshot_id
    
    def initialize(id:, name:, status:, test_run_id:, folder_snapshot_id: nil)
      @id = id
      @name = name
      @status = status
      @test_run_id = test_run_id
      @folder_snapshot_id = folder_snapshot_id
      @related_scenario_jira_id = nil
    end
    
    def api_method
      "testrun_testsnapshot"
    end
    
    def api_arguments
      [ENV['HT_PROJECT'], @test_run_id.to_s, @id.to_s]
    end
    
    def api_path
      API::Hiptest.base_url + "/projects/#{ENV['HT_PROJECT']}/test_runs/#{@test_run_id}/test_snapshots"
    end
    
    def related_scenario
      unless @related_scenario_jira_id
        scenario_res = @@api.get(URI("#{api_path}/#{@id}?include=scenario"))
        related_scenario_id = scenario_res.dig('included').first.dig('id')
        
        tags_res = @@api.get_scenario_tags(ENV['HT_PROJECT'], related_scenario_id)
        binding.pry if tags_res.dig('data').select{|tag| tag.dig('attributes', 'key') == 'JIRA'}.first.nil?
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
      case status
      when "passed"
        color = "green"
      when "unexecuted"
        status = "undefined"
        color = "uncolorize"
      when "failed"
        color = "red"
      else
        color = "uncolorize"
      end
      
      output("-- #{@name} => " + status.send(color))
      begin
        @@api.post(URI("#{api_path}/#{@id}/test_results"), result_data(status, author, description))
        File.open(@@results_path, "a") do |line|
          line.puts @id
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        puts 'Something bad happened'.red
        puts e
      end
    end
    
    def is_already_pushed
      @@pushed_results.select{ |ts_id| ts_id == @id}.any?
    end
    
    def self.process_results
      File.open(@@results_path, 'r').each do |line|
        @@pushed_results << line.sub("\n", '')
      end
    end
  end
end
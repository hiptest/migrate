require 'pry'
require 'nokogiri'
require 'singleton'
require 'net/http'
require "uri"
require "json"

require './lib/models/project'
require './lib/models/folder'
require './lib/models/scenario'
require './lib/models/actionword'
require './lib/models/parameter'
require './lib/models/dataset'
require './lib/models/tag'
require './lib/models/test_run'

require './lib/utils/string'

module Parser
  class Zephyr
    @@to_tag_nodes = [:link, :environment, :key, :priority, :status, :fixVersion, :labels, :versions, :issueKey]
    @@only_key_tags = []
    
    attr_accessor :execution, :info
    
    def initialize(execution:, info: nil)
      @execution = execution
      @info = info
    end
    
    def self.is_info_file?(info)
      info.xpath('//item').any? and info.xpath('//item/project').any? and info.xpath('//item/summary') and info.xpath('//item/type')[0].text === 'Test'
    end

    def self.is_execution_file?(execution)
      execution.xpath('//execution').any? and execution.xpath('//execution/project').any? and execution.xpath('//execution/testSummary').any?
    end

    def process_infos
      raise 'Information file is not well-formed' unless Zephyr.is_info_file?(@info)
      
      tests_nodes = @info.xpath('//item')

      tests_nodes.each do |test_node|
        sc = {}

        test_node.element_children.each do |child|
          sc[child.name.to_sym] = child.content.strip.safe
        end

        scenario = Models::Scenario.find_by_jira_id(sc[:key])
        if scenario
          scenario.description = sc[:description]

          sc[:labels].split("\n").map do |label|
            label.strip!
            next if label.empty?

            scenario.tags << Models::Tag.new(:label, label)
          end
        end
      end
    end


    def process_executions
      raise 'Execution file is not well-formed' unless Zephyr.is_execution_file?(@execution)
      
      tests_nodes = @execution.xpath('//execution')
      tests_nodes.each do |test_node|
        execution = {}
        steps = []

        test_node.element_children.each do |child|
          if child.name == 'teststeps'
            child.element_children.each do |step_node|
              test_step = {}
              step_node.element_children.each do |step_attribute|
                test_step[step_attribute.name.to_sym] = step_attribute.content.strip.safe
              end
              steps << test_step unless test_step[:step].empty? && test_step[:result].empty?
            end
          else
            execution[child.name.to_sym] = child.content.strip.safe
          end
        end

        Models::Project.instance.name = execution[:project]
        
        tr = Models::TestRun.find_or_create_by_name(execution[:cycleName])
        
        scenario = Models::Scenario.new(execution[:testSummary].double_quotes_replaced.single_quotes_escaped, steps)
        
        author = execution[:executedBy].empty? ? "Migration script" : execution[:executedBy]

        tr.add_status_to_cache(scenario: scenario, status: execution[:executedStatus].downcase, author: author, description: "")
        
        scenario.steps.each do |stp|
          unless stp.dig(:data).empty?
            aw_name = stp.dig(:step).empty? ? stp.dig(:result) : stp.dig(:step)
            aw = Models::Actionword.find_or_create_by_name(aw_name)
            scenario.add_unique_actionword(aw)
          end
        end

        @@to_tag_nodes.each do |tag|
          if tag == :issueKey
            next if execution[tag].nil? or execution[tag].empty?

            scenario.jira_id = execution[tag]
            scenario.tags << Models::Tag.new(:JIRA, execution[tag])
            next
          end

          unless @@only_key_tags.include? tag
            scenario.tags << Models::Tag.new(tag, execution[tag]) unless execution[tag].nil? or execution[tag].empty?
          else
            scenario.tags << Models::Tag.new(tag)
          end
        end

        folder = nil
        unless execution[:components].empty?
          folder = Models::Folder.find_or_create_by_name(execution[:components])
          folder.scenarios << scenario
        else
          Models::Project.instance.scenarios << scenario
        end
      end
    end
  end
end

#!/usr/bin/env ruby
require 'pry'
require 'nokogiri'
require 'singleton'
require 'net/http'
require "uri"
require "json"

require './lib/models/project'
require './lib/models/folder'
require './lib/models/scenario'
require './lib/models/parameter'
require './lib/models/dataset'
require './lib/models/tag'

TO_TAG_NODES = [:link, :environment, :key, :priority, :status, :fixVersion, :labels, :versions, :issueKey]
ONLY_KEY_TAGS = []
HIPTEST_API_URI = ENV['HT_URI'] || 'https://hiptest.net/api'


def parse_files(paths)
  files = []

  paths.each do |path|
    if File.file?(path) and path.end_with?('.xml')
      files << File.open(path) { |f| Nokogiri::XML(f)}
    end
  end

  files
end

def is_info_file? file_nodes
  file_nodes.xpath('//item').any? and file_nodes.xpath('//item/project').any? and file_nodes.xpath('//item/summary') and file_nodes.xpath('//item/type')[0].text === 'Test'
end

def is_execution_file? file_nodes
  file_nodes.xpath('//execution').any? and file_nodes.xpath('//execution/project').any? and file_nodes.xpath('//execution/testSummary').any?
end


def determinate_info_and_execution_files(files)
  infos, executions = nil

  files.each do |file|
    if is_info_file? file
      infos = file
    end

    if is_execution_file? file
      executions = file
    end
  end

  if infos.nil? or executions.nil?
    help
    exit(1)
  end

  [infos, executions]
end




###########################
#       PROCESSING        #
###########################

def process_infos(infos_nodes)
  tests_nodes = infos_nodes.xpath('//item')

  tests_nodes.each do |test_node|
    sc = {}

    test_node.children.each do |child|
      sc[child.name.to_sym] = child.content.strip
    end

    scenario = Models::Scenario.find_by_jira_id(sc[:key])
    if scenario
      scenario.description = sc[:description].gsub(%r{</?[^>]+?>}, '')

      sc[:labels].split("\n").map do |label|
        label.strip!
        next if label.empty?

        scenario.tags << Models::Tag.new('label', label)
      end
    end
  end
end


def process_executions(executions_nodes)
  tests_nodes = executions_nodes.xpath('//execution')
  tests_nodes.each do |test_node|
    execution = {}
    steps = []

    test_node.element_children.each do |child|
      if child.name == 'teststeps'
        child.element_children.each do |step_node|
          test_step = {}
          step_node.element_children.each do |step_attribute|
            test_step[step_attribute.name.to_sym] = step_attribute.content.strip
          end
          steps << test_step
        end
      else
        execution[child.name.to_sym] = child.content.strip
      end
    end

    Models::Project.instance.name = execution[:project]
    scenario = Models::Scenario.new(execution[:testSummary], steps)

    TO_TAG_NODES.each do |tag|
      if tag == :issueKey
        next if execution[tag].nil? or execution[tag].empty?

        scenario.jira_id = execution[tag]
        scenario.tags << Models::Tag.new('JIRA', execution[tag])
        next
      end

      unless ONLY_KEY_TAGS.include? tag
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



###########################
#           MAIN          #
###########################

if __FILE__ == $0
  check_env_variables
  if ARGV.count == 2
    files = parse_files(ARGV)
    infos, executions = determinate_info_and_execution_files(files)
    process_executions(executions)
    process_infos(infos)
    Models::Project.instance.save
  else
    help
    exit(1)
  end
end

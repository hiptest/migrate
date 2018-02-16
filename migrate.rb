#!/usr/bin/env ruby
require 'optparse'
require 'active_support/inflector'
require 'pry'

require './lib/parsers/zephyr'
require './lib/env'

def parse_file(path)
  file = nil
  if File.file?(path) and path.end_with?('.xml')
    file = Nokogiri::XML(File.open(path)) do |config|
      config.noent
    end
  end
  file
end

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: migrate.rb [options]"
  
  options[:verbose] = false
  opts.on('-v', '--verbose', 'Display more informations') do
    options[:verbose] = true
  end
  
  opts.on('-h', '--help', 'Display usage and options') do
    puts opts
    exit
  end
  
  options[:from] = 'zephyr'
  opts.on('-fNAME', '--from=NAME', 'Select source you want to import from (zephyr)') do |from|
    source = from.singularize
    case source
    when /zephyr/
      options[:from] = 'zephyr'
    else
      puts 'You can only choose between: zephyr'
    end
  end
  
  if options[:from] == 'zephyr'
    opts.on('-iINFOS_FILE', '--info=INFOS_FILE', 'Zephyr informations file') do |infos_file|
      options[:infos_file] = infos_file
    end
    
    opts.on('-eEXECUTIONS_FILE', '--execution=EXECUTIONS_FILE', 'Zephyr executions file') do |executions_file|
      options[:executions_file] = executions_file
    end
  end
  
  options[:only] = nil
  opts.on('-o', '--only', 'Specify the action you want to be done') do |action_param|
    case action_param
    when /import/
      action = :import
    when /push_results/
      action = :push_result
    else
      action = nil
    end
    options[:only] = action
  end
end


###########################
#           MAIN          #
###########################

if __FILE__ == $0
  optparse.parse!
  
  if options[:infos_file].nil? && !options[:infos_file].empty? && options[:executions_file].nil? && !options[:executions_file].empty?
    puts "For zephyr migration, you must specify both '--info' and '-execution' options"
    exit
  end
  
  puts
  puts "Hi, #{options[:from]} migration will start in a second.".green
  puts
  
  if options[:from] == 'zephyr'
    check_env_variables
    configure_api_from_env(verbose: options[:verbose])
    
    infos = parse_file(options[:infos_file])
    executions = parse_file(options[:executions_file])
    
    process_executions(executions)
    process_infos(infos)
    
    case options[:only]
    when :push_results
      Models::TestRun.push_results
    when :import
      Models::Project.instance.save
    else
      Models::Project.instance.save
      puts
      puts 'Data migration is finished.'.green
      puts 'Push execution results!'.green
      puts
      Models::TestRun.push_results
    end
    
    puts
    puts "Migration is finished".green
    
    link = "https://hiptest.net"
    if ENV['HT_URI']
      link = ENV['HT_URI']
    end
    link += "/projects/#{ENV['HT_PROJECT']}"
    puts "Go to '".green + link.uncolorize + "' to see imported project".green
    puts "Enjoy! :)".green
    puts
  end
end

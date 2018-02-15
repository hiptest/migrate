#!/usr/bin/env ruby
require 'optparse'
require 'active_support/inflector'
require 'pry'

require './lib/parsers/zephyr'
require './lib/env'

def parse_file(path)
  file = nil
  if File.file?(path) and path.end_with?('.xml')
    file = File.open(path) { |f| Nokogiri::XML(f)}
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
  
  options[:test_run_id] = nil
  opts.on('-tTEST_RUN_ID', '--test_run=TEST_RUN_ID', 'Specify the test-run id if you want to push execution results') do |test_run_id|
    options[:test_run_id] = test_run_id
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
  
  if options[:from] == 'zephyr'
    check_env_variables
    configure_api_from_env(verbose: options[:verbose])
    
    infos = parse_file(options[:infos_file])
    executions = parse_file(options[:executions_file])
    
    process_executions(executions)
    process_infos(infos)
    
    Models::Project.instance.save
  end
end

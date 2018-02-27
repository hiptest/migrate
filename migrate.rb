#!/usr/bin/env ruby

require 'optparse'
require 'active_support/inflector'
require 'pry'

require './lib/parsers/zephyr'
require './lib/env'

class Migration
  attr_reader :parser, :options

  Version = '1.0.0'

  IMPORTERS = %w[zephyr]

  class ScriptOptions
    attr_accessor :from, :zephyr_info_file, :zephyr_execution_file,
                  :only, :verbose

    def initialize
      self.from = 'zephyr'
      self.zephyr_info_file = ''
      self.zephyr_execution_file = ''
      self.only = ''
      self.verbose = false
    end

    def define_options(parser)
      parser.banner = "Usage: migrate.rb [options]"
      parser.separator ""
      parser.separator "Global options:"

      from_option(parser)
      only_option(parser)
      verbose_option(parser)

      parser.separator ""
      parser.separator "Specific options:"
      parser.separator ""
      parser.separator "  Zephyr:"

      zephyr_info_file_option(parser)
      zephyr_execution_file_option(parser)

      parser.separator ""
      parser.separator "Common options:"

      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end

      parser.on_tail("--version", "Show version") do
        puts Version
        exit
      end
    end

    def from_option(parser)
      from_list = IMPORTERS.join(', ')
      parser.on("-f", "--from FROM", IMPORTERS, "Select importer", "(#{from_list})") do |from|
        self.from = from.downcase
      end
    end

    def only_option(parser)
      parser.on("-o", "--only [ACTION]", [:import, :push_results], "Specify what to do (import, push_results)", "import: import scenarios", "push_results: import test execution results") do |only|
        self.only = only
      end
    end

    def zephyr_info_file_option(parser)
      parser.on("-i", "--info FILE", "Zephyr information xml file") do |info_file|
        self.zephyr_info_file = info_file
      end
    end

    def zephyr_execution_file_option(parser)
      parser.on("-e", "--execution FILE", "Zephyr execution xml file") do |execution_file|
        self.zephyr_execution_file = execution_file
      end
    end

    def verbose_option(parser)
      parser.on("-v", "--[no-]verbose", "Run verbosely") do |verbose|
        self.verbose = verbose
      end
    end
  end

  def parse_options(args)
    @options = ScriptOptions.new
    @parser = OptionParser.new do |parser|
      @options.define_options(parser)
    end
    @args = @parser.parse!(args)
    @options
  end

  def check_options
    check_zephyr_options if @options.from = 'zephyr'
  end

  def migrate
    create_temp_dir
    check_env_variables
    configure_api_from_env(verbose: @options.verbose)
    case @options.from
    when 'zephyr'
      process_zephyr
    end

    migrate_xml
  end

  private

  def create_temp_dir
    Dir.mkdir('./tmp') unless File.exist?('./tmp')
  end

  def check_zephyr_options
    return if @options.from != 'zephyr'
    
    if @options.zephyr_execution_file.empty?
      raise "Zephyr import requires an execution xml file"
    end
    
    unless @options.only == :push_results
      if @options.zephyr_info_file.empty?
        raise "Zephyr import requires an information xml file"
      end
    end
  end
  
  def process_zephyr
    zephyr_parser = Parser::Zephyr.new(execution: parse_xml_file(@options.zephyr_execution_file))
    zephyr_parser.process_executions
    
    if options.only != :push_results
      zephyr_parser.info = parse_xml_file(@options.zephyr_info_file)
      zephyr_parser.process_infos
    end
  end

  def migrate_xml
    puts

    case @options.only
    when :push_results
      puts 'Push execution results!'.green
      puts
      Models::TestRun.push_results
    when :import
      puts 'Import data in Hiptest'
      puts
      Models::Project.instance.save
    else
      puts 'Import data in Hiptest'
      puts
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

  def parse_xml_file(path)
    xml = nil
    if File.file?(path) and path.end_with?('.xml')
      xml = Nokogiri::XML(File.open(path)) do |config|
        config.noent
      end
    end
    xml
  end
end

if __FILE__ == $0
  begin
    migration = Migration.new
    migration.parse_options(ARGV)
    migration.check_options
    migration.migrate
  rescue OptionParser::InvalidOption => error
    puts error.message.red
    puts migration.parser.help
  rescue => error
    puts error.message.red
    puts error.backtrace.map { |s| "  #{s}" }.join("\n").red
    puts migration.parser.banner
  end
end

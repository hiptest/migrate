require 'spec_helper'
require 'nokogiri'

require './lib/parsers/zephyr'
require './lib/models/project'
require './lib/models/scenario'

describe "Migrate Zephyr script" do
  let(:info_file) {
    Nokogiri::XML(File.open('./spec/xml_samples/infos.xml')) do |config|
      config.noent
    end
  }

  let(:exec_file) {
    Nokogiri::XML(File.open('./spec/xml_samples/executions.xml')) do |config|
      config.noent
    end
  }
  
  def reset_all
    project = Models::Project.instance
    instance_variable_names = project.instance_variables.map{ |attr| attr.to_s.sub('@', '')}
    
    instance_variable_names.each do |attr|
      if project.send("#{attr}").kind_of?(Array)
        project.send("#{attr}=", [])
      else
        project.send("#{attr}=", nil)
      end
    end
    
    Models::Scenario.class_variable_set(:@@scenarios, [])
  end
  
  context '#is_info_file' do
    it "return true if its an info xml export" do
      expect(is_info_file?(info_file)).to be_truthy
    end
    
    it "return false if its not an info xml export" do
      expect(is_info_file?(exec_file)).to be_falsy
    end
  end
  
  context '#is_execution_file' do
    it "return true if its an execution xml export" do
      expect(is_execution_file?(exec_file)).to be_truthy
    end
    
    it "return false if its not an execution xml export" do
      expect(is_execution_file?(info_file)).to be_falsy
    end
  end
  
  context '#process_executions' do
    before do
      reset_all
    end
    
    it 'construct project correctly and remove unsafe chars from name' do
      process_executions(exec_file)
      
      project = Models::Project.instance
      expect(project.name).to eq "Blopidou 'pidiboup' lksdf"
    end
    
    it 'construct scenarios correctly and remove unsafe chars from name' do
      process_executions(exec_file)
      
      project = Models::Project.instance
      
      expect(project.scenarios.count).to eq 1
      scenario = project.scenarios.first
      
      expect(scenario.name).to eq 'Blopidou test'
      expect(scenario.jira_id).to eq 'JIRA-1'
    end
    
    it 'produce correct scenario definition' do
      process_executions(exec_file)
      
      scenario = Models::Project.instance.scenarios.first
      
      definition = "scenario 'Blopidou test' do\n"
      definition += " step { action: \"Log in to GOT portal\" }\n"
      definition += " step { result: \"Log in should be done successfully\" }\n"
      definition += " step { action: \"Click on \\'Lannister house\\'\" }\n"
      definition += " step { result: \"\\'Lannister house\\' screen should get opened\" }\n"
      definition += " call 'Enter name of each Lannister childs. then click \\'Apply\\' button' (__free_text = \"01.Jamie - Lannister \\\n"
      definition += "02. Cersei - Lannister\\\n"
      definition += "03. Tyrion - Lannister\\\n"
      definition += "04.Joffrey - Baratheon\\\n"
      definition += "05.Myrcella - Baratheon\\\n"
      definition += "06. Tommen - Baratheon\")\n"
      definition += " step { result: \"Every child should be listed\" }\n"
      definition += "end"
      
      expect(scenario.definition).to eq definition
    end
    
    it 'add tags to scenarios' do
      process_executions(exec_file)
      
      tags = Models::Project.instance.scenarios.first.tags
      
      expect(tags.count).to eq 3
      expect(tags.map(&:key)).to eq [:priority, :versions, :JIRA]
      expect(tags.map(&:value)).to eq ["Minor", "Unscheduled", "JIRA-1"]
    end
    
    it 'construct actionwords correctly' do
      process_executions(exec_file)
      
      actionwords = Models::Project.instance.scenarios.first.actionwords
      
      expect(actionwords.count).to eq 1
      expect(actionwords.first.name).to eq "Enter name of each Lannister childs. then click \\'Apply\\' button"
    end
  end
  
  context '#process_infos' do
    before do
      reset_all
      
      process_executions(exec_file)
      @project = Models::Project.instance
    end
    
    it 'add description to scenarios' do
      process_infos(info_file)
      expect(@project.scenarios.first.description).to eq 'A super description of this test with tagtag/tag in it'
    end
    
    it 'add labels as tags' do
      process_infos(info_file)
      labels = @project.scenarios.first.tags.select{ |tag| tag.key == :label }
      expect(labels.map(&:value)).to eq ["SIT"]
    end
  end
end
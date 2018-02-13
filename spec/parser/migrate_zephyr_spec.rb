require 'spec_helper'

require 'nokogiri'

require './migrate_zephyr'
require './lib/models/project'

describe "Migrate Zephyr script" do
  let(:info_file) {
    File.open('./spec/xml_samples/infos.xml') { |f| Nokogiri::XML(f)}
  }

  let(:exec_file) {
    File.open('./spec/xml_samples/executions.xml') { |f| Nokogiri::XML(f)}
  }
  
  def reset_project
    project = Models::Project.instance
    instance_variable_names = project.instance_variables.map{ |attr| attr.to_s.sub('@', '')}
    
    instance_variable_names.each do |attr|
      if project.send("#{attr}").kind_of?(Array)
        project.send("#{attr}=", [])
      else
        project.send("#{attr}=", nil)
      end
    end
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
  
  context '#determinate_info_and_execution_files' do
    it 'return info file first and execution in second' do
      info, execution = determinate_info_and_execution_files([exec_file, info_file])
      expect(is_info_file?(info)).to be_truthy
      expect(is_execution_file?(execution)).to be_truthy
    end
  end
  
  context '#process_executions' do
    before do
      reset_project
    end
    
    it 'construct project correctly' do
      process_executions(exec_file)
      
      project = Models::Project.instance
      expect(project.name).to eq 'Blopidou project'
    end
    
    it 'construct scenarios correctly' do
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
      definition += " step { action: \"Click on 'Lannister house'\" }\n"
      definition += " step { result: \"'Lannister house' screen should get opened\" }\n"
      definition += " call 'Enter name of each Lannister childs. then click \\'Apply\\' button' (__free_text = \"01.Jamie - Lannister \n"
      definition += "02. Cersei - Lannister\n"
      definition += "03. Tyrion - Lannister\n"
      definition += "04.Joffrey - Baratheon\n"
      definition += "05.Myrcella - Baratheon\n"
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
end
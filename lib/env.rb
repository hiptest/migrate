def get_env_variables
  {
    access_token: ENV['HT_ACCESS_TOKEN'],
    client: ENV['HT_CLIENT'],
    uid: ENV['HT_UID'],
    project_id: ENV['HT_PROJECT']
  }
end

def check_env_variables
  env_var_names = ['HT_ACCESS_TOKEN', 'HT_CLIENT', 'HT_UID', 'HT_PROJECT']
  is_errored = false

  env_var_names.each do |env_var|
    if ENV[env_var].nil?
      is_errored = true
      puts "#{var_name} environment variable is missing, please export it to push to Hiptest."
    end
  end

  if is_errored
    puts
    puts "Usage"
    puts "./migrate_zephyr.rb file1.xml file2.xml"
    puts
    puts "Some environment variables are required to push your project to Hiptest. Please export them in your terminal session or specify them before the script call."
    puts "\tHT_ACCESS_TOKEN:\tYou may find it in your Hiptest profile page"
    puts "\tHT_CLIENT:\t\tYou may find it in your Hiptest profile page"
    puts "\tHT_UID:\t\t\tYou may find it in your Hiptest profile page"
    puts "\tHT_PROJECT:\t\tYou may find it in the Url of your project. http://hiptest.net/app/projects/<project_id>"
    puts
    puts "Example: HT_ACCESS_TOKEN=xxxxxx HT_CLIENT=xxxxxx HT_UID=xxxxxx HT_PROJECT=xxxx ./migrate_zephyr.rb file1.xml file2.xml"
    exit(1)
  end
end

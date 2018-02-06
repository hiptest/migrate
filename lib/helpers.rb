def missing_env(var_name)
  puts "#{var_name} environment variable is missing, please export it to push to Hiptest."
end

def help
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
end

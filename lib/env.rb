require './lib/helpers'

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
      missing_env(env_var)
    end
  end

  if is_errored
    puts
    help
    exit(1)
  end
end


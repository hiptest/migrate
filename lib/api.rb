require './lib/env'
require 'net/http'
require "uri"

def get(uri)
  req = Net::HTTP::Get.new(uri.path)
  send_request(uri, req)
end

def post(uri, body)
  req = Net::HTTP::Post.new(uri.path)
  req.body = body

  send_request(uri, req)
end

def patch(uri, body)
  req = Net::HTTP::Patch.new(uri.path)
  req.body = body

  send_request(uri, req)
end

def send_request(uri, req)
  res = nil

  add_auth_header_to_request(req)
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => HIPTEST_API_URI.start_with?('https')) do |http|
    http.request(req)
  end

  if response.code == "200"
    res = JSON.parse(response.body)
  else
    if response.code == 429
      puts "API limit rate exceeded, sleeping for a while"
      sleep 310
      puts "Ok, let's start again"
      return send_request(uri, req)
    else
      binding.pry
    end
    puts response.message
  end

  res
end

def exists?(resource, uri, attribute_name, attribute)
  exist = false
  res = get(uri)

  if res and res['data'].any?
    res['data'].each do |r|
      if r.dig('attributes', attribute_name) == attribute
        exist = true
        resource.id = r.dig('id')
      end
    end
  end

  exist
end

def create_or_update(resource, body, resource_type = nil, already_called = false)
  res = nil

  if resource.api_exists?
    resource.api_path += "/#{resource.id}"
    uri = URI(api_path)

    body[:data][:attributes].delete(:name) unless resource_type == 'parameters'
    body[:data][:type] = resource_type
    body[:data][:id] = resource.id

    res = patch(uri, body.to_json)
  else
    uri = URI(resource.api_path)
    res = post(uri, body.to_json)
    if res
      resource.id = res.dig('data', 'id')
      if resource_type == "scenarios" && !already_called
        res = create_or_update(resource, body, resource_type, true)
      end
    else
      STDERR.puts "Error while creating/updating #{resource_type} with : #{body}"
    end
  end

  res
end

def add_auth_header_to_request(request)
  headers.each do |name, value|
    request[name] = value
  end
end

def headers
  env_variables = get_env_variables
  {
    "Content-Type" => "application/json",
    "Accept" => "application/vnd.api+json; version=1",
    "access-token" => "#{env_variables[:access_token]}",
    "client" => "#{env_variables[:client]}",
    "uid" => "#{env_variables[:uid]}"
  }
end


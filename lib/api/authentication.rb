module API
  module Authentication
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def add_auth_header_to_request(request)
      headers.each do |name, value|
        request[name] = value
      end
    end
    
    def headers
      config = self.class.configuration
      {
        "Content-Type" => "application/json",
        "Accept" => "application/vnd.api+json; version=1",
        "access-token" => "#{config.access_token}",
        "client" => "#{config.client}",
        "uid" => "#{config.uid}"
      }
    end
    
    module ClassMethods
      def authenticate(email, password)
        self.arrange_base_url!
        
        uri = URI(self.base_url + 'auth/sign_in')
        
        req = Net::HTTP::Post.new(uri.path)
        req.body = { email: email, password: password }.to_json
        
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => self.use_ssl) do |http|
          http.request(req)
        end
        
        raise "Authentication failed" unless response.code == "200"
        
        auth_vars = {}
        
        response.each_header do |field|
          auth_vars[field] = response.header[field]
        end
        
        self.configure do |config|
          config.access_token = auth_vars.dig("access-token")
          config.client = auth_vars.dig("client")
          config.uid = auth_vars.dig("uid")
        end
      end
    end
  end
end
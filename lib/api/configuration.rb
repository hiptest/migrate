module API
  module Configuration
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def configure
        self.arrange_base_url!
        self.configuration ||= API::Configuration::Configuration.new
        yield(configuration)
      end
    end
    
    class Configuration
      attr_accessor :access_token, :client, :uid
      
      def initialize
        @access_token = access_token
        @client = client
        @uid = uid
      end
    end
  end
end
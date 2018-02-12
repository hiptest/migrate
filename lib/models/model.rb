require './lib/api/hiptest'

module Models
  class Model
    @@api = API::Hiptest.new
    
    def self.api
      @@api
    end
    
    def self.api= api
      @@api = api
    end
    
    attr_accessor :id, :name

    def api_path
      raise NotImplementedError
    end

    def create_data
      raise NotImplementedError
    end

    def update_data
      base = create_data
      base[:data][:id] = @id
      base[:data][:type] = data_type
      base
    end

    def api_exists_url
      api_path
    end

    def api_identical?(result)
      result.dig('attributes', 'name') == @name
    end

    def find_idential_result(results)
      exist = false

      results.each do |r|
        if api_identical?(r)
          exist = true
          @id = r.dig('id')
          break
        end
      end

      exist
    end

    def api_exists?
      res = @@api.get(URI(api_exists_url))
      res and res['data'].any? ? find_idential_result(res['data']) : false
    end

    def save
      if api_exists?
        res = update
      else
        res = create
      end

      after_save(res)
      res
    end

    def after_save(data)
    end

    def create
      output "-- Creating #{resource_type} object #{name}"
      res = @@api.post(URI(api_path), create_data)
      if res
        @id = res.dig('data', 'id')
      else
        STDERR.puts "Error while creating #{resource_type} with : #{create_data}"
      end
      after_create(res)
      res
    end

    def after_create(data)
    end

    def update
      output "-- Updating #{self.class.name.split('::').last} object #{name} (id: #{id})"
      begin
        res = @@api.patch(URI("#{api_path}/#{id}"), update_data)
      rescue => error
        STDERR.puts "Error while updating #{resource_type} with : #{update_data}" unless res
        raise error
      end

      after_update(res)
    end

    def after_update(data)
    end

    def resource_type
      self.class.name.split('::').last
    end

    private

    def output(str)
      puts str unless ENV['ZEPHYR_POC_SILENT']
    end
  end
end

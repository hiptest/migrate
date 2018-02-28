require './lib/api/hiptest'
require './lib/utils/string'

module Models
  class Model
    @@api = API::Hiptest.new

    def api_method
      resource_type.uncapitalize
    end

    def api_arguments
      [ENV['HT_PROJECT'], @id.to_s]
    end

    def self.api
      @@api
    end

    def self.api= api
      @@api = api
    end

    attr_accessor :id, :name

    def create_data
      raise NotImplementedError
    end

    def update_data
      base = create_data
      base[:data][:id] = @id
      base[:data][:type] = data_type
      base
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
      return true if @id
      res = @@api.send("get_#{api_method.pluralize}", *api_arguments[0...-1])
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

    def after_save(data=nil)
    end

    def create
      output "-- Creating #{resource_type} object #{name}"
      res = @@api.send("create_#{api_method.singularize}", *api_arguments[0...-1], create_data)
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

    def before_update
    end

    def update
      before_update

      output "-- Updating #{self.class.name.split('::').last} object #{name} (id: #{id})"
      begin
        res = @@api.send("update_#{api_method.singularize}", *api_arguments, update_data)
      rescue => error
        STDERR.puts "Error while updating #{resource_type} with : #{update_data}" unless res
        raise error
      end

      after_update(res)
    end

    def after_update(data)
    end

    def data_type
      resource_type.pluralize.underscore.gsub('_', '-')
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

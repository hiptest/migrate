require './lib/api'

module Models
  class Model
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

    def api_exists?
      exist = false
      res = get(URI(api_exists_url))

      if res and res['data'].any?
        res['data'].each do |r|
          if api_identical?(r)
            exist = true
            @id = r.dig('id')
          end
        end
      end

      exist
    end

    def save
      if api_exists?
        res = update
      else
        res = create
      end

      after_save
      res
    end

    def after_save
    end

    def create
      puts "-- Creating #{self.class.name.split('::').last} object #{name}"
      res = post(URI(api_path), create_data.to_json)
      after_create

      if res
        id = res.dig('data', 'id')
      else
        STDERR.puts "Error while creating/updating #{resource_type} with : #{body}"
      end
      res
    end

    def after_create
    end

    def update
      puts "-- Updating #{self.class.name.split('::').last} object #{name}"

      res = patch(URI("#{api_path}/#{id}"), update_data.to_json)
      after_update
    end

    def after_update
    end
  end
end

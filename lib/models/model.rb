require './lib/api'

module Models
  class Model
    attr_accessor :id, :name

    def api_path
      raise NotImplementedError
    end

    def api_data
      raise NotImplementedError
    end

    alias :api_exists_url :api_path

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
        patch(URI("#{api_path}/#{id}"), api_data.to_json)
      else
        res = post(URI(api_path), api_data.to_json)

        if res
          resource.id = res.dig('data', 'id')
        else
          STDERR.puts "Error while creating/updating #{resource_type} with : #{body}"
        end
        res
      end
    end
  end
end

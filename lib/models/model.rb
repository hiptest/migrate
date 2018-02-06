require './lib/api'

module Models
  class Model
    attr_accessor :id, :name

    def api_path
      raise NotImplementedError
    end

    def api_exists?
      exist = false
      res = get(URI(api_path))

      if res and res['data'].any?
        res['data'].each do |r|
          if r.dig('attributes', 'name') == normalized_name
            exist = true
            @id = r.dig('id')
          end
        end
      end

      exist
    end
  end
end

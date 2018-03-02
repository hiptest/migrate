require 'active_support/inflector'

require './lib/api/hiptest'
require './lib/utils/string'
require './lib/api/routing/dispatcher'

module API
  module Routing
    def method_missing(name, *args, data: nil, **kwargs)
      dispatcher = Dispatcher.new(self, name, *args, data: data, **kwargs)
      dispatcher.perform
    end
  end
end

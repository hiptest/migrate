require 'active_support/inflector'

require './lib/api/hiptest'
require './lib/utils/string'
require './lib/api/routing/projects'
require './lib/api/routing/scenarios'
require './lib/api/routing/test_snapshots'
require './lib/api/routing/dispatcher'

module API
  module Routing
    def method_missing(name, *args)
      dispatcher = Dispatcher.new(self, name, args)
      dispatcher.perform
    end

    include API::Routing::Projects
    include API::Routing::Scenarios
    include API::Routing::TestSnapshots
  end
end

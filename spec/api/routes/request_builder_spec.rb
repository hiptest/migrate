require './lib/api/routing/request_builder'

module API
  module Routing
    RSpec.describe RequestBuilder do

      let(:scenario_route) { Routes.lookup("scenario") }

      before do
        ENV['HT_PROJECT'] = "1"
      end

      it 'works with index' do
        request = RequestBuilder.new(scenario_route, "index", [1])
        expect(request.build_url).to eq("https://hiptest.net/api/projects/1/scenarios")
      end

      it 'works with get' do
        request = RequestBuilder.new(scenario_route, "show", [1, 5])
        expect(request.build_url).to eq("https://hiptest.net/api/projects/1/scenarios/5")
      end
    end
  end
end

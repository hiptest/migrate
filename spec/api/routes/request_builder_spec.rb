require './lib/api/routing/request_builder'

module API
  module Routing
    RSpec.describe RequestBuilder do

      let(:scenario_route) { Routes.lookup("scenario") }
      let(:project_route) { Routes.lookup("project") }
      let(:root_scenarios_folder_route) { Routes.lookup('root_scenarios_folder') }

      before do
        ENV['HT_PROJECT'] = "1"
      end

      it 'works with index' do
        request = RequestBuilder.new(scenario_route, [1])
        expect(request.build_url).to eq("https://hiptest.net/api/projects/1/scenarios")
      end

      it 'works with get' do
        request = RequestBuilder.new(scenario_route, [1, 5])
        expect(request.build_url).to eq("https://hiptest.net/api/projects/1/scenarios/5")
      end

      it 'supports both args as an array ([1, 2]) or as an *args list (1, 2)' do
        request_array = RequestBuilder.new(scenario_route, [1, 5])
        request_splat = RequestBuilder.new(scenario_route, 1, 5)
        expect(request_array.build_url).to eq(request_splat.build_url)
      end

      it 'adds keyword args as query parameters' do
        request = RequestBuilder.new(project_route, 1, include: 'scenarios-folder')
        expect(request.build_url).to eq('https://hiptest.net/api/projects/1?include=scenarios-folder')
        request = RequestBuilder.new(project_route, 1, include: 'scenarios-folder', polop: 1)
        expect(request.build_url).to eq('https://hiptest.net/api/projects/1?include=scenarios-folder&polop=1')
      end

      it 'escapes query parameters as needed' do
        request = RequestBuilder.new(project_route, q: %q{It's "escaped"_%42_😎_<>})
        expect(request.build_url).to eq('https://hiptest.net/api/projects?q=It%27s%20%22escaped%22_%2542_%F0%9F%98%8E_%3C%3E')
      end

      it 'respects route default params' do
        request = RequestBuilder.new(root_scenarios_folder_route, 17)
        expect(request.build_url).to eq('https://hiptest.net/api/projects/17?include=scenarios-folder')
      end

      it 'merges route default params' do
        request = RequestBuilder.new(root_scenarios_folder_route, 17, hello: 'world')
        expect(request.build_url).to eq('https://hiptest.net/api/projects/17?include=scenarios-folder&hello=world')
      end

      it 'works with routes with empty segments (no id in the segment)' do
        route = Routes.lookup('scenarios_by_jira_id')
        request = RequestBuilder.new(route, 17, value: 'hello')
        expect(request.build_url).to eq('https://hiptest.net/api/projects/17/scenarios/find_by_tags?key=JIRA&value=hello')
      end

      it 'differentiates data from other args' do
        data = { name: 'hello world' }
        request = RequestBuilder.new(scenario_route, 12, data: data)
        expect(request.build_url).to eq('https://hiptest.net/api/projects/12/scenarios')
        expect(request.data).to eq(data)
      end
    end
  end
end
